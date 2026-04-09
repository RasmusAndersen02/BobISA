structure L4test =
struct

  type blockCFG = string * string list
  type funcCFG = string * L4.args * blockCFG list * L4.pos

  fun blockName [] = "<unnamed>"
    | blockName (l :: _) = l

  fun addLabelTargets [] _ table = table
    | addLabelTargets (l :: ls) blockId table =
        addLabelTargets ls blockId ((l, blockId) :: table)

  fun buildLabelTable [] table = table
    | buildLabelTable (((inLabels, _, _), _, _) :: bs) table =
        buildLabelTable bs (addLabelTargets inLabels (blockName inLabels) table)

  fun lookupBlockId label [] = label
    | lookupBlockId label ((l, blockId) :: table) =
        if l = label then blockId else lookupBlockId label table

  fun dedup [] = []
    | dedup (x :: xs) =
        if List.exists (fn y => y = x) xs then dedup xs else x :: dedup xs

  fun cfgOfBlock labelTable ((inLabels, _, _), _, (_, outLabels, _)) =
    let
      val source = blockName inLabels
      val succs =
        dedup
          (List.map
             (fn label =>
                 if label = "End" then "End" else lookupBlockId label labelTable)
             outLabels)
    in
      (source, succs)
    end

  fun buildFuncCFG (fname, args, blocks, pos) : funcCFG =
    let
      val labelTable = buildLabelTable blocks []
      val blockCFG = List.map (cfgOfBlock labelTable) blocks
    in
      (fname, args, blockCFG, pos)
    end

end
