mosmlc -c L4prim.sml
mosmlc -c L4.sml
mosmlyac -v L4parser.grm
mosmlc -c L4parser.sig L4parser.sml
mosmllex L4lexer.lex
mosmlc -c L4lexer.sml
mosmlc -c L4check.sml
mosmlc -c L4type.sml
mosmlc -c L4int.sml
mosmlc -o l4i l4i.sml
