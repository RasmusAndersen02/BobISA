(* L4 interpreter core module *)
structure L4int =
struct
(* calls first function in program *)
(* input and output are of type string list *)
(* Each list is one input.  First inArgs, then roArgs *)
(* Output is outArgs and then roArgs *)

  exception Error of string * (int * int)

  val counter = ref 0

  (* find name in table, raise error if not found *)
  fun lookup x [] pos = raise Error (x ^ " not found", pos)
    | lookup x ((y,v) :: table) pos =
         if x=y then v else lookup x table pos

  (* find name in table, return option type *)
  fun lookup1 x [] pos = NONE
    | lookup1 x ((y,v) :: table) pos =
         if x=y then SOME v else lookup1 x table pos

  (* remove first occurence of name from table, raise error if not found *)
  fun remove x [] pos = raise Error (x ^ " not found", pos)
    | remove x ((y,v) :: table) pos =
         if x=y then table else (y,v) :: remove x table pos

  (* find function in program, raise error if not found *)
  fun lookFun f [] pos = raise Error (f ^ " not found", pos)
    | lookFun f ((g, roArgs, bs, pos1) :: funs) pos =
         if f=g then (roArgs, bs, pos1) else lookFun f funs pos

  fun printVtable1 [] = TextIO.output(TextIO.stdErr, ";\n")
    | printVtable1 ((x,v)::vtable) =
        (TextIO.output(TextIO.stdErr, x ^ " = " ^ v ^ "\n"); printVtable1 vtable)
	
  (* print vtable on stdErr *)
  fun printVtable _ = ()
  (* fun printVtable vt =
    (TextIO.output(TextIO.stdErr, ">>"); printVtable1 vt) *)

  (* Bind declared variables to values *)
  fun addArgs [] [] vTable pos = vTable
    | addArgs (L4.ConstD (w, t) :: args) (v :: input) vTable pos =
        if v = w then addArgs args input vTable pos
	else raise Error ("arg " ^ v ^ " does not mach constant " ^ w, pos)
    | addArgs (L4.VarD (x, t) :: args) (v :: input) vTable pos =
        (x, v) :: addArgs args input vTable pos
    | addArgs [] input vTable pos =
        (printVtable1 vTable;
         raise Error ("Too many inputs: " ^ String.concatWith " " input, pos))
    | addArgs args [] vTable pos =
        (printVtable1 vTable;
         raise Error ("Too few inputs", pos))

  (* return values of consumed variables and updated vTable *)
  fun consume [] vTable pos = ([], vTable)
    | consume (L4.ConstD (value, typ) :: args) vTable pos =
        let
	  val (values, vTable1) = consume args vTable pos
	in
	  (value :: values, vTable1)
	end
    | consume (L4.VarD (x, typ) :: args) vTable pos =
        let
	  val (values, vTable1) = consume args vTable pos
	in
	  (lookup x vTable1 pos :: values, remove x vTable1 pos)
	end
	
  (* return values of arguments  *)
  fun getValues [] vTable pos = []
    | getValues (L4.ConstD (value, typ) :: args) vTable pos =
        value :: getValues args vTable pos
    | getValues (L4.VarD (x, typ) :: args) vTable pos =
        lookup x vTable pos :: getValues args vTable pos

  (* look up block by entry label in list of blocks *)
  fun lookupBlock lab [] pos = raise Error ("label " ^ lab ^ " not found", pos)
    | lookupBlock lab ((b as ((labs1, _, _), _, _)) :: bs) pos =
        if List.exists (fn l => l = lab) labs1 then b
        else lookupBlock lab bs pos

  (* bind control variable to number of called label *)
  fun bindControl control [] lab n pos =
        raise Error ("label not found: " ^ lab, pos)
    | bindControl control (l1 :: labs) lab n pos =
        if l1 = lab then
	  case control of
	    L4.ConstD (c, t) =>
	      if c = Int.toString n then []
	      else raise Error ("control constant doesn't match use", pos)
	  | L4.VarD (c, t) => [(c, Int.toString n)]
	else  bindControl control labs lab n pos

  fun indexOf x [] = 1000
    | indexOf x (y::ys) = if x=y then 0 else 1 + indexOf x ys

  (* execute single instruction *)
  fun runIn i vTable roTable pgm =
    case i of
      L4.Prim (name, inArgs, roArgs, outArgs, pos) =>
        let
	  val () = printVtable vTable
	  val roValues = getValues roArgs (roTable @ vTable) pos
	  val (inValues, vTable1) = consume inArgs vTable pos
	  val () = printVtable vTable1
	  val outValues = L4prim.applyPrim name inValues roValues pos
	  val vTable2 = addArgs outArgs outValues vTable1 pos
	in
	  printVtable vTable2 ;
	  vTable2
	end
    | L4.Call (name, inArgs, roArgs, outArgs, pos) =>
        let
	  val roValues = getValues roArgs (roTable @ vTable) pos
	  val (inValues, vTable1) = consume inArgs vTable pos
	  val outValues = call name pgm pos true roValues inValues
	  val vTable2 = addArgs outArgs outValues vTable1 pos
	in
	  vTable2
	end
    | L4.Uncall (name, inArgs, roArgs, outArgs, pos) =>
        let
	  (* val () = TextIO.output(TextIO.stdErr, "uncall " ^ name ^": ") *)
	  val () = printVtable vTable
	  val roValues = getValues roArgs (roTable @ vTable) pos
	  val (inValues, vTable1) = consume inArgs vTable pos
	  val () = printVtable vTable1
	  val outValues = call name pgm pos false roValues inValues
	  val vTable2 = addArgs outArgs outValues vTable1 pos
	in
	  printVtable vTable2 ;
	  vTable2
	end

  (* execute instructions in a block *)
  and runIns [] exit vTable roTable bs pgm =
        (counter := !counter + 1;
         runExit exit vTable roTable bs pgm)
    | runIns (i::is) exit vTable roTable bs pgm =
        let
          val () = counter := !counter + 1
	  val vTable1 = runIn i vTable roTable pgm
	in
	  runIns is exit vTable1 roTable bs pgm
	end

  (* execute exit of block *)
  and runExit (args, labels, pos) vTable roTable bs pgm =
    let
      val (argValues0, vTable1) = consume args vTable pos
      val (control, argValues) =
            case argValues0 of
              (control :: argValues) => (control, argValues)
	    | _ => raise Error ("No args at", pos)
      val lab = List.nth (labels, Option.getOpt (Int.fromString control, 0))
      val () = printVtable vTable
    in
      if lab = "End" then
        if vTable1 = [] then argValues (* return from function *)
	else raise Error ("Nonempty environment at End", pos)
      else runBlock lab argValues bs roTable vTable1 pgm pos (* jump *)
    end
	
  (* jump to blok *)
  and runBlock lab (args : string list) bs roTable vars pgm pos =
    let
      val () = counter := !counter + 1
      val ((labs1, args1, pos2), ins, exit) = lookupBlock lab bs pos
      val (control, args2) = case args1 of
                                (control :: args2) => (control, args2)
			     | _ => raise Error ("No args at", pos)
      val vTable1 = addArgs args2 args vars pos2
      val controlValue = indexOf lab labs1
      val vTable2 = bindControl control labs1 lab controlValue pos2 @ vTable1
      val () = printVtable vTable2
    in
      runIns ins exit vTable2 roTable bs pgm
    end

  (* call function *)
  and call fname pgm pos forwards
           (roIns : string list) (consumedIns : string list) =
    let
      val (roArgs, bs, pos1) = lookFun fname pgm pos
      val roTable = addArgs roArgs roIns [] pos1
    in
      if forwards then
        runBlock "Begin" consumedIns bs roTable [] pgm pos1
      else
        runBlock "Begin" consumedIns (List.map L4.invertBlock bs)
	         roTable [] pgm pos1
    end

  (* Run program by calling first function *)
  fun run pgm (input : string list) =
        case pgm of
	  [] => raise Error ("Empty program", (0,0))
        | ((fname, roArgs, bs, pos) :: fs) =>
	    let
	      val result =
	            call fname pgm pos true
	                 (List.take (input, List.length roArgs))
	                 (List.drop (input, List.length roArgs))
	    in
	      TextIO.output (TextIO.stdErr,
	                     Int.toString (!counter) ^ " steps executed\n");
	      result
	    end
	    
end
