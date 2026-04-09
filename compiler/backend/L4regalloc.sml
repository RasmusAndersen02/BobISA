structure L4regalloc =
  struct

  type allocations = (string * int) list

  val initAllocation : allocations = []
  val numOfRegs = 16

  fun regAllocator (currAllocations : allocations, funcName: string) :
    allocations =
    let
      val nextIdx = List.length currAllocations + 1
    in
      if nextIdx >= numOfRegs then
        raise Fail ("Exceeds number of regs: " ^ Int.toString numOfRegs)
      else 
        (funcName, nextIdx) :: currAllocations
    end

  fun allocateRegs (initAllocations : allocations, funcNames: string list) :
    allocations = 
    List.foldr (fn (funcName, allocationList) => regAllocator(allocationList, funcName))
      initAllocations funcNames

end
