signature L4cfg =
sig
  type ID = int
  type Lbl = string
  type Var = string
  datatype Dir = Entries | Exits


  (*for effecient lookup of block specs*)
  val block_id_mapping : L4.block list -> L4.block Intmap.intmap
  (*for effecient lookup for Labels*)
  val label_to_id_mapping : 
    L4.block Intmap.intmap * Dir -> 
    (Lbl, ID) Binarymap.dict 
  (*Intsets for set operations in liveness*)
  val single_node : 
    L4.block * (Lbl, ID) Binarymap.dict * (Lbl, ID) Binarymap.dict -> 
    (ID list * ID list)  
  
  val control_flow_graph : 
    (ID * L4.block) list * (Lbl, ID) Binarymap.dict * (Lbl, ID) Binarymap.dict * (ID list * ID list) Intmap.intmap-> 
    (ID list * ID list) Intmap.intmap

end
