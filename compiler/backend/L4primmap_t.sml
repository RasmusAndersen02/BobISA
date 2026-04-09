structure L4primmap =
struct


  datatype InstrSig =
      Bin of string * reg * reg
    | Un of string * reg
    | Imm of string * reg * int
    | RegOff of string * reg * int
    | Off of string * int
    | Lbl of string

  datatype primMapping = 
    Direct of InstrSig list
  | Helper of string
  | Codegen

  fun regToString (Reg r) = "reg" ^ Int.toString r

  fun instrToString (Bin (keyword, d, s)) = 
      keyword ^ " " ^ regToString d ^ ", " ^ regToString s
    | instrToString (Un (keyword, r)) = 
      keyword ^ " " ^ regToString r
    | instrToString (Imm (keyword, r, i)) = 
      keyword ^ " " ^ regToString r ^ ", " ^ Int.toString i
    | instrToString (RegOff (keyword, r, off)) = 
      keyword ^ " " ^ regToString r ^ ", " ^ Int.toString off
    | instrToString (Off (keyword, off)) = 
      keyword ^ " " ^ Int.toString off
    | instrToString (Lbl s) = "_" ^ s ^ "_"

  fun mapPrim name inArgs roArgs outArgs =
    let
      val empty = []
    in
      case (name, inArgs, roArgs, outArgs) of
        ("+", [d], [s], [r]) => Direct [Bin ("ADD", d, s)]
      | ("-", [d], [s], [r]) => Direct [Bin ("SUB", d, s)]
      | ("*", _, _, _) => Helper "mul"
      | ("/", _, _, _) => Helper "div"
      | ("%", _, _, _) => Helper "mod"
      | ("%1", _, _, _) => Helper "mod_check"
      | ("=", [d], [x, y], [r]) => 
          Direct [Bin ("XOR", d, x), Bin ("SUB", d, y), RegOff ("BGEZ", d, 2), Off ("BRA", 1), Imm ("XORI", d, 0)]
      | ("<", [d], [x, y], [r]) => 
          Direct [Bin ("SUB", d, x), RegOff ("BLZ", d, 1), Imm ("XORI", d, 0)]
      | ("not", [d], [], [r]) => Direct [Imm ("XORI", d, 1)]
      | ("odd", [d], [x], [r]) => Direct [RegOff ("BODD", x, 1), Imm ("XORI", d, 0)]
      | ("rol1", [d], [], [r]) => Direct [Un ("MUL2", d)]
      | ("ror1", [d], [], [r]) => Direct [Un ("DIV2", d)]
      | ("rol", _, _, _) => Helper "rol"
      | ("ror", _, _, _) => Helper "ror"
      | ("swap", [d, v], [i], [a, r]) => Direct [Bin ("EXCH", d, v)]
      | ("test", _, _, _) => Codegen
      | ("test2", _, _, _) => Codegen
      | ("test3", _, _, _) => Codegen
      | _ => Direct empty
    end

end
