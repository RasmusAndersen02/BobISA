structure L4primmap =
struct

  datatype reg = Reg of int
  datatype InstrSignature =
      BinArith of string * reg * reg
    | UniArith of string * reg
    | ImmArith of string * reg * int
    | BranchReg of string * reg
    | BranchOff of string * string
    | BranchRegOff of string * reg * string
    | Exch of string * reg * reg
    | Lbl of string

  fun instrEmit BinArith (keyword, regd, regs) : string =
      keyword ^ " " ^ "reg" ^ Int.toString regd ^ ", " ^ "reg" ^ Int.toString regs
    | instrEmit UniArith (keyword, regd) = 
      keyword ^ " " ^ "reg" ^ Int.toString regd
    | instrEmit ImmArith (keyword, regd, imm) =
      keyword ^ " " ^ "reg" ^ Int.toString regd ^ ", " ^ Int.toString imm
    | instrEmit BranchReg (keyword, regd) = 
      keyword ^ " " ^ "reg" ^ Int.toString regd
    | instrEmit BranchOff (keyword, ref) = 
      keyword ^ " " ^ ref
    | instrEmit BranchRegOff (keyword, regd, ref) = 
      keyword ^ " " ^ "reg" ^ Int.toString regd ^ ", " ^ ref
    | instrEmit Exch (keyword, regd, rega) = 
      keyword ^ " " ^ "reg" ^ Int.toString regd ^ ", " ^ "reg" ^ Int.toString rega 
      
  fun instrMap operator:string dRegs:reg list sRegs:reg list : instrSignature list =
    case operator of 
      "+" => [BinArith ("ADD", hd dRegs, hd sRegs)]
    | "-" => [BinArith ("SUB", hd dRegs, hd sRegs)]
    | "rol1" => [UniArith ("MUL2", hd dRegs)]
    | "ror1" => [UniArith ("DIV2", hd dRegs)]
    | _ => NONE



end

