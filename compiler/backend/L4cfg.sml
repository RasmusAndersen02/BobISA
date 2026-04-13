structure L4cfg :> L4cfg =
struct
  open Intmap
  open Intset
  open Binarymap

  type ID = int
  type Lbl = string
  type Var = string
  datatype Dir = Entries | Exits 
  (*maps blocks with integer ID 0...n-1*)
  fun block_id_mapping 
    (blockList: L4.block list) 
    : L4.block Intmap.intmap  =
    let
      fun add_block (block: L4.block, (next_id: ID, id_map: L4.block Intmap.intmap)) =
        let val updated_map = Intmap.insert (id_map, next_id, block)
        in (next_id + 1, updated_map)
      end

      val init_accum = (0, Intmap.empty ())
      val (_, block_id_map) = List.foldl add_block init_accum blockList
    in block_id_map
  end

  fun get_labels 
    (block: L4.block, Entries: Dir) 
    : Lbl list =
    let val ((entry_labels,_,_),_,(_,_,_)) = block
    in entry_labels
  end
    | get_labels (block : L4.block, Exits: Dir) : Lbl list =
    let val ((_,_,_),_,(_,exit_labels,_)) = block
    in exit_labels
  end


  fun label_to_id_mapping 
    (block_id_map: L4.block Intmap.intmap, dir:Dir) 
    : (Lbl, ID) Binarymap.dict =
    let
      fun add_block_labels (id: ID, block: L4.block, label_map) =
        List.foldl
          (fn (label, accum) => Binarymap.insert (accum, label, id))
          label_map
          (get_labels (block, dir))

      val empty_label_map = Binarymap.mkDict String.compare
    in
      Intmap.foldl add_block_labels empty_label_map block_id_map
  end
  
  fun single_node (block: L4.block, entry_map:(Lbl, ID) Binarymap.dict,
    exit_map: (Lbl, ID) Binarymap.dict) 
    : (ID list * ID list) = 
    let
      val entry_labels = get_labels (block, Entries)
      val exit_labels = get_labels (block, Exits)
      val out_edges = List.foldl 
        (fn (lbl, accum) => Binarymap.find (entry_map, lbl) :: accum)
        [] 
        exit_labels
      val in_edges = List.foldl 
        (fn (lbl, accum) => Binarymap.find (exit_map, lbl) :: accum)
        [] 
        entry_labels
    in
      (in_edges, out_edges)
    end

  fun control_flow_graph ([], _, _, cfg) = cfg
    | control_flow_graph 
    ((id, block)::block_ass_list: (ID * L4.block) list, entry_map: (Lbl, ID)
    Binarymap.dict, exit_map: (Lbl, ID) Binarymap.dict, cfg: (ID list * ID list)
    Intmap.intmap) 
    : (ID list * ID list) Intmap.intmap = 
    let
      val new_node = single_node (block, entry_map, exit_map)
      val new_cfg = Intmap.insert (cfg, id, new_node)
    in
      control_flow_graph (block_ass_list, entry_map, exit_map, new_cfg)
  end
    
  fun main 
    (blocks: L4.block list) 
    : (ID list * ID list) Intmap.intmap =
    let 
      val block_id_map = block_id_mapping (blocks)
      val entry_map = label_to_id_mapping (block_id_map, Entries)
      val exit_map = label_to_id_mapping (block_id_map, Exits)
      val block_ass_list = Intmap.listItems block_id_map
    in 
      control_flow_graph (block_ass_list, entry_map, exit_map, Intmap.empty())
  end




    


  



end
