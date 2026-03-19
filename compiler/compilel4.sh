#!/bin/bash

cd "$(dirname "$0")"

mosmlc -c -I frontend -I backend frontend/L4prim.sml
mosmlc -c -I frontend -I backend frontend/L4.sml

mosmlyac -v frontend/L4parser.grm
mosmlc -c -I frontend -I backend frontend/L4parser.sig frontend/L4parser.sml
mosmllex frontend/L4lexer.lex
mosmlc -c -I frontend -I backend frontend/L4lexer.sml

mosmlc -c -I frontend -I backend frontend/L4check.sml
mosmlc -c -I frontend -I backend frontend/L4type.sml

mosmlc -o l4c -I frontend -I backend backend/l4c_t.sml
# mosmlc -c L4int.sml
# mosmlc -o l4i l4i.sml
