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
  type EntryList = (Label * BlockID) list
  type ExitList = (BlockID * Label) list



  fun block_table (entry_list : EntryList, exit_list : ExitList, block_id : BlockID) =
    let
      val 


        case List.find (fn (exit_id,_) => exit_id = block_id) exit_list of
          SOME (_, exit_label) => exit_label
        | NONE => raise Fail "asdfas"

      val out_edges : BlockID list = List.map (fn out_label =>
        case List.find (fn (entry_label, entry_id) => entry_label = out_label) entry_list of
          SOME (_, entry_id)=> entry_id
        | NONE => raise Fail "asdfas"
      ) out_labels
    in
      out_edges
    end


  fun succs (entry_list : EntryList, exit_list : ExitList, block_id : BlockID) =
    let

      val out_labels : Label list = List.map (fn (exit_id, _) =>
        case List.find (fn ())
      )

      val out_labels : Label list = 
        case List.find (fn (exit_id,_) => exit_id = block_id) exit_list of
          SOME (_, exit_label) => exit_label
        | NONE => raise Fail "asdfas"

      val out_edges : BlockID list = List.map (fn out_label =>
        case List.find (fn (entry_label, entry_id) => entry_label = out_label) entry_list of
          SOME (_, entry_id)=> entry_id
        | NONE => raise Fail "asdfas"
      ) out_labels
    in
      out_edges
    end

  fun populate_cfg_edges (block_graph : CFG, entry_list : EntryList, exit_list :
    ExitList) : CFG =
    let
      
    in

    end

  fun build_cfg ([] : L4.block list, block_graph : CFG, entry_list :
    EntryList, exit_list : ExitList) : CFG = 
    populate_cfg_edges (block_graph, entry_list, exit_list)

  | build_cfg (curr_block::block_list : L4.block list, block_graph : CFG,
  entry_list : EntryList, exit_list : ExitList) : CFG = 
    let
      val ((block_entries,entry_args,_),_,(exit_args,block_exits,_)) = curr_block
      val entry_vars = map (fn (L4.ConstD (const_val,_)) => const_val 
                             | (L4.VarD (variable_name,_)) => variable_name)
                             entry_args
      val exit_vars = map (fn (L4.ConstD (const_val,_)) => const_val 
                             | (L4.VarD (variable_name,_)) => variable_name)
                             exit_args
      val curr_node =
        {id = List.length block_list + 1
        ,pred = [] : BlockID list
        ,succ = [] : BlockID list
        ,liveIn = entry_vars : Var list
        ,liveOut = exit_vars : Var list
        }
      val list_entry = map (fn entry_label => (entry_label, #id curr_node)) block_entries
      val list_exit = map (fn exit_label => (#id curr_node, exit_label)) block_exits

    in
      build_cfg (block_list, curr_node::block_graph, list_entry @ entry_list,
      list_exit @ exit_list )
    end

end

  
