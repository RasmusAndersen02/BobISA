structure l4c_t =
struct

  datatype reg = Reg of int

  type allocation = (string * reg) list

  val emptyAlloc : allocation = []

  val numRegs = 16

  fun allocReg (alloc, name) =
    case List.find (fn (n, _) => n = name) alloc of
      SOME (_, r) => (alloc, r)
    | NONE =>
        let
          val next = length alloc + 1
        in
          if next >= numRegs then
            raise Fail ("Num of Vars exceed 16")
          else
            let val r = Reg next
            in ((name, r) :: alloc, r) end
        end

  fun allocRegs (alloc, names) =
    let
      fun go ([], alloc, regs) = (alloc, rev regs)
        | go (n::ns, alloc, regs) =
            let val (alloc', r) = allocReg (alloc, n)
            in go (ns, alloc', r::regs) end
    in go (names, alloc, []) end

  fun lookupReg (alloc, name) =
    case List.find (fn (n, _) => n = name) alloc of
      SOME (_, r) => r
    | NONE => raise Fail ("Variable not allocated: " ^ name)

  fun regToString (Reg r) = "reg" ^ Int.toString r

  datatype InstrSig =
      Bin of string * reg * reg
    | Un of string * reg
    | Imm of string * reg * int
    | RegOff of string * reg * int
    | Off of string * int
    | Lbl of string

  fun instrToString (Bin (nm, d, s)) = 
      nm ^ " " ^ regToString d ^ ", " ^ regToString s
    | instrToString (Un (nm, r)) = 
      nm ^ " " ^ regToString r
    | instrToString (Imm (nm, r, i)) = 
      nm ^ " " ^ regToString r ^ ", " ^ Int.toString i
    | instrToString (RegOff (nm, r, off)) = 
      nm ^ " " ^ regToString r ^ ", " ^ Int.toString off
    | instrToString (Off (nm, off)) = 
      nm ^ " " ^ Int.toString off
    | instrToString (Lbl s) = "_" ^ s ^ "_"

  fun getDeclName (L4.VarD (x, _)) = x
    | getDeclName (L4.ConstD (x, _)) = x

  fun mapPrim name inArgs roArgs outArgs =
    let
      val empty : InstrSig list = []
    in
      case (name, length inArgs, length roArgs, length outArgs) of
        ("+", 2, 0, 1) => SOME [Bin ("ADD", hd inArgs, hd (tl inArgs))]
      | ("-", 2, 0, 1) => SOME [Bin ("SUB", hd inArgs, hd (tl inArgs))]
      | ("*", _, _, _) => NONE
      | ("/", _, _, _) => NONE
      | ("%", _, _, _) => NONE
      | ("%1", _, _, _) => NONE
      | ("=", 1, 2, 1) => 
          SOME [Bin ("XOR", hd inArgs, hd roArgs), Bin ("SUB", hd inArgs, hd (tl roArgs)), RegOff ("BGEZ", hd inArgs, 2), Off ("BRA", 1), Imm ("XORI", hd inArgs, 0)]
      | ("<", 1, 2, 1) => 
          SOME [Bin ("SUB", hd inArgs, hd roArgs), RegOff ("BLZ", hd inArgs, 1), Imm ("XORI", hd inArgs, 0)]
      | ("not", 1, 0, 1) => SOME [Imm ("XORI", hd inArgs, 1)]
      | ("odd", 1, 1, 1) => SOME [RegOff ("BODD", hd roArgs, 1), Imm ("XORI", hd inArgs, 0)]
      | ("rol1", 1, 0, 1) => SOME [Un ("MUL2", hd inArgs)]
      | ("ror1", 1, 0, 1) => SOME [Un ("DIV2", hd inArgs)]
      | ("rol", _, _, _) => NONE
      | ("ror", _, _, _) => NONE
      | ("swap", 2, 1, 2) => SOME [Bin ("EXCH", hd inArgs, hd (tl inArgs))]
      | _ => SOME empty
    end

  fun allocEntry (alloc, args) =
    let
      val names = map getDeclName args
    in
      allocRegs (alloc, names)
    end

  fun translateInstr alloc (L4.Prim (prim, inArgs, roArgs, outArgs, pos)) =
    let
      val inNames = map getDeclName inArgs
      val roNames = map getDeclName roArgs
      val outNames = map getDeclName outArgs
      val allNames = inNames @ roNames @ outNames
      val (alloc', _) = allocRegs (alloc, allNames)
      val inRegs = map (fn n => lookupReg (alloc', n)) inNames
      val roRegs = map (fn n => lookupReg (alloc', n)) roNames
      val outRegs = map (fn n => lookupReg (alloc', n)) outNames
    in
      case mapPrim prim inRegs roRegs outRegs of
        SOME instrs => (alloc', instrs)
      | NONE => raise Fail ("Unsupported primitive: " ^ prim)
    end

  fun translateBlock alloc (entry, instrs, exit) =
    let
      val (_, args1, _) = entry
      val (alloc', _) = allocEntry (alloc, args1)
      fun go ([], alloc, acc) = (alloc, rev acc)
        | go (i::is, alloc, acc) =
            let 
              val (alloc', instrs') = translateInstr alloc i
            in go (is, alloc', rev instrs' @ acc) end
      val (alloc'', instrs') = go (instrs, alloc', [])
    in
      (instrs', alloc'')
    end

  fun translateFunc (funcName, args, blocks, pos) =
    let
      val (alloc, _) = allocEntry (emptyAlloc, args)
      fun goBlock ([], alloc, acc) = (alloc, rev acc)
        | goBlock (b::bs, alloc, acc) =
            let
              val (instrs, alloc') = translateBlock alloc b
            in
              goBlock (bs, alloc', acc @ instrs)
            end
      val (_, allInstrs) = goBlock (blocks, alloc, [])
    in
      (funcName, allInstrs)
    end

  fun emitInstrs instrs =
    concat (map (fn i => instrToString i ^ "\n") instrs)

  fun compile filename =
    let
      val is = TextIO.openIn filename
      val lexbuf = Lexing.createLexer (fn b => fn n =>
        let
          val s = TextIO.inputN (is, n)
          val len = size s
        in
          CharArray.copyVec {src=s, dst=b, di=0};
          len
        end)
      val program = L4parser.Program L4lexer.Token lexbuf
      val _ = TextIO.closeIn is
      val funcs = map translateFunc program
    in
      funcs
    end
    handle e => (print ("Error: " ^ (exnMessage e) ^ "\n"); [])

  fun main () =
    let
      val args = CommandLine.arguments ()
      val funcs = compile (hd args)
    in
      app (fn (_, instrs) => print (emitInstrs instrs)) funcs
    end

  val _ = main ()

end
