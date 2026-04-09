structure L4liveness =
struct

  type BlockID = int
  type Label = string
  type Var = string
  type Node = 
    {
    id : BlockID
    , pred : BlockID list
    , succ : BlockID list
    , liveIn : Var list
    , liveOut : Var list
    }
  type CFG = Node list 
  type BlockLabelMap = (BlockID * Label) list
  type BlockTable = (BlockID * BlockID list * BlockID list) list

  fun explode_relations (curr_block::block_list : L4.block list, entry_map :
    BlockLabelMap, exit_map : BlockLabelMap) : (BlockLabelMap * BlockLabelMap) =
    let
      val block_id = List.length block_list + 1
      val ((entry_labels,_,_),_,(_,exit_labels,_)) = curr_block
      val entry_explode = List.map (fn entry_label => (block_id, entry_label))
      entry_labels
      val exit_explode = List.map (fn exit_label => (block_id, exit_label))
      exit_labels
    in 
      explode_relations (block_list, entry_explode @ entry_map,
      exit_explode @ exit_map)
    end 
  | explode_relations ([], entry_map :
    BlockLabelMap, exit_map : BlockLabelMap) =
    (entry_map, exit_map)
  
  fun build_out_edges (_, _, out_edges, 0) = out_edges 
  | build_out_edges (entry_map : BlockLabelMap, exit_map : BlockLabelMap,
    out_edges : (BlockID * BlockID) list, curr_id : BlockID) :
    (BlockID * BlockID) list =
    let
      (*Partitions all exits into those that belongs to the current block and
      * those that dont*)
      val (exit_hits, exit_remainder) = List.partition (fn (block_id,_) => block_id = curr_id) exit_map
      val exit_labels = List.map #2 exit_hits
      (*Partitions all entries into those that matches one of the exits from
      * above and those that dont*)
      val (entry_hits, entry_remainder) = List.partition (fn (_, entry_label) =>
        List.exists (fn exit_label => entry_label = exit_label) exit_labels
      ) entry_map 
      val entry_ids = List.map #1 entry_hits
      val explode_out_edges = List.map (fn out_edge => (curr_id, out_edge))
      entry_ids
    in 
      build_out_edges (entry_remainder, exit_remainder, explode_out_edges @
      out_edges, curr_id-1)
    end

  fun in_edges_derivation (_, block_table, 0) = block_table
  | in_edges_derivation (out_edges : (BlockID * BlockID) list, block_table : BlockTable, curr_id : BlockID) : BlockTable =
    let
      val curr_out = List.map (fn (_, dest) => dest) (List.filter (fn (origin, _) => origin = curr_id ) out_edges)
      val curr_in = List.map (fn (origin,_) => origin) (List.filter (fn (_, dest) => dest = curr_id ) out_edges)
    in 
      in_edges_derivation (out_edges, (curr_id, curr_in, curr_out)::block_table, curr_id-1)
    end

  fun build_block_table (block_list : L4.block list) : BlockTable =
    let
      val (entry_map, exit_map) = explode_relations(block_list, [], [])
      val init_id = List.length block_list
      val out_edges = build_out_edges (entry_map, exit_map, [], init_id)
    in 
      in_edges_derivation (out_edges, [], init_id)
    end 



end
