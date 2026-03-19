(* L4 interpreter *)
(* compile with mosmlc l4i.sml -o l4i *)
structure l4i =
struct

  exception Exit

  fun createLexerStream ( is : BasicIO.instream ) =
      Lexing.createLexer ( fn buff => fn n => Nonstdio.buff_input is buff 0 n)

  fun errorMess s = (TextIO.output (TextIO.stdErr,s ^ "\n"); raise Exit)

  (* converts string list to string *) 
  fun makeLines ll = String.concatWith "\n" ll

  fun l4run filename input backwards =  
      let
        val lexbuf = createLexerStream
			  (BasicIO.open_in (filename))
      in
        let
          val pgm = L4parser.Program L4lexer.Token lexbuf
	  val () = L4check.check pgm
	  val () = L4type.check pgm
	  val output =
	    if backwards
	    then L4int.run (L4.invertFun (hd pgm) :: tl pgm) input
	    else L4int.run pgm input
        in
          TextIO.output (TextIO.stdOut, makeLines output ^ "\n")
        end
          handle Parsing.yyexit ob => errorMess "Parser-exit\n"
               | Parsing.ParseError ob =>
                   let val (lin,col) = L4lexer.getPos lexbuf
                   in
                     errorMess ("Parse-error at line "
                      ^ makestring lin ^ ", column " ^ makestring col)
                   end
               | L4lexer.LexicalError (mess,(lin,col)) =>
                     errorMess ("Lexical error: " ^mess^ " at line "
                      ^ makestring lin ^ ", column " ^ makestring col)
               | L4check.Error (mess, (lin,col)) =>
                     errorMess ("Check error: " ^mess^ " at line "
                      ^ makestring lin ^ ", column " ^ makestring col)
               | L4type.Error (mess, (lin,col)) =>
                     errorMess ("Type error: " ^mess^ " at line "
                      ^ makestring lin ^ ", column " ^ makestring col)
               | L4int.Error (mess, (lin,col)) =>
                     errorMess ("Runtime error: " ^mess^ " at line "
                      ^ makestring lin ^ ", column " ^ makestring col)
               | L4prim.Error (mess, (lin,col)) =>
                     errorMess ("primitive function error: " ^mess^ " at line "
                      ^ makestring lin ^ ", column " ^ makestring col)
               | SysErr (s,_) => errorMess ("Exception: " ^ s)
               | Subscript =>  errorMess "subscript error"
      end

  val input : string list =
    let
      val txt = TextIO.inputAll TextIO.stdIn
    in
      String.tokens (fn c => c = #"\n") txt
    end
      

  val _ =
    let
      val cmdLine = Mosml.argv ()
    in
      if List.length cmdLine = 2 then
        let
	  val fname = (List.nth(cmdLine,1))
	in
	  if String.isSuffix ".l4" fname
          then l4run fname input false
          else  errorMess "call by  'l4 test.l4' or 'l4 -r test.l4'"
	end
      else if List.length cmdLine = 3 then
        let
	  val option = (List.nth(cmdLine,1))
	  val fname = (List.nth(cmdLine,2))
	in
	  if option = "-r" andalso String.isSuffix ".l4" fname
          then l4run fname input true
          else  errorMess "call by  'l4 test.l4' or 'l4 -r test.l4'"
	end
      else  errorMess "call by  'l4 test.l4' or 'l4 -r test.l4'"
    end
    handle Exit => ()

end
