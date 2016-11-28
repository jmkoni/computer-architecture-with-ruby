# @author Jennifer Konikowski <jmkoni@icloud.com>
# This class represents a simulation of a computer pipeline.
# Initialization:
#     simulation = PipelineSim.new(starting_address)
#     simulation.runthrough(instructions)
# Definition of parameters:
#     starting_address: starting address of the first instruction (in hex)
#     instructions: array of mips instructions, in hex
# Example:
#     > instructions = ["0x00a63820",
#                       "0x8d0f0004",
#                       "0xad09fffc",
#                       "0x00625022",
#                       "0x00000000",
#                       "0x00000000",
#                       "0x00000000",
#                       "0x00000000"]
#     > simulation = PipelineSim.new("0x70000")
#     > simulation.runthrough(instructions)

class PipelineSim
  # Returns (and sets) current content of the IF/ID Register
  # @return [PipelineRegister] contents of pipeline register, including title, read, and write
  attr_accessor :IfIdRegister
  # Returns (and sets) current content of the ID/EX Register
  # @return [PipelineRegister] contents of pipeline register, including title, read, and write
  attr_accessor :IdExRegister
  # Returns (and sets) current content of the EX/MEM Register
  # @return [PipelineRegister] contents of pipeline register, including title, read, and write
  attr_accessor :ExMemRegister
  # Returns (and sets) current content of the MEM/WB Register
  # @return [PipelineRegister] contents of pipeline register, including title, read, and write
  attr_accessor :MemWbRegister
  # Returns (and sets) main memory
  # @return [MainMem] representation of current main memory
  attr_accessor :mainMem
  # Returns (and sets) registers
  # @return [Regs] representation of current registers
  attr_accessor :regs
  # Returns starting_address
  # @return [String] starting address in hex
  attr_reader   :starting_address
  # Returns (and sets) cycle number
  # @return [Integer] current cycle number
  attr_accessor :cycle_num
  # Initializes new PipelineSim object
  # @param starting_address [String] starting address in hex
  # @example Create a new pipeline simulation
  #     simulation = PipelineSim.new("0x70000")
  # @return [PipelineSim] new PipelineSim object
  # @note With this simulation, there are 32 registers and a 1K main memory
  def initialize(starting_address)
    @mainMem = MainMem.new('7FF'.to_i(16))
    @regs = Regs.new(32)
    @cycle_num = 0
    @starting_address = starting_address
    @IfIdRegister = PipelineRegister.new("IF/ID Register", {instruction: "0x00000000"})
    @IdExRegister = PipelineRegister.new("ID/EX Register", {control: "000000000"})
    @ExMemRegister = PipelineRegister.new("EX/MEM Register", {control: "000000000"})
    @MemWbRegister = PipelineRegister.new("MEM/WB Register", {control: "000000000"})
  end

  # Takes an array of operations and performs them on the cache
  # @param instructions [Array] an array of strings representing MIPS instructions
  # @return [void]
  # @note This function prints out after each cycle (prior to copying write to read)
  # @example Given an example array of instructions
  #     simulation.runthrough(["0x00a63820", "0x8d0f0004"])
  #     => to screen:
  #     -----------------
  #     | Clock Cycle 1 |
  #     -----------------
  #     Regs: 0, 101, 102, 103, 104, 105, 106, 107, 108, 109, 10a, 10b, 10c, 10d, 10e, 10f, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 11a, 11b, 11c, 11d, 11e, 11f, 120


  #     IF/ID Register Write
  #     --------------------
  #     instruction = 0x00a63820  incrPC = 70004

  #     IF/ID Register Read
  #     --------------------
  #     instruction = 0x00000000


  #     ID/EX Register Write
  #     --------------------
  #     control = 000000000

  #     ID/EX Register Read
  #     --------------------
  #     control = 000000000


  #     EX/MEM Register Write
  #     --------------------
  #     control = 000000000

  #     EX/MEM Register Read
  #     --------------------
  #     control = 000000000


  #     MEM/WB Register Write
  #     --------------------
  #     control = 000000000

  #     MEM/WB Register Read
  #     --------------------
  #     control = 000000000


  #     -----------------
  #     | Clock Cycle 2 |
  #     -----------------
  #     Regs: 0, 101, 102, 103, 104, 105, 106, 107, 108, 109, 10a, 10b, 10c, 10d, 10e, 10f, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 11a, 11b, 11c, 11d, 11e, 11f, 120


  #     IF/ID Register Write
  #     --------------------
  #     instruction = 0x8d0f0004  incrPC = 70008

  #     IF/ID Register Read
  #     --------------------
  #     instruction = 0x00a63820  incrPC = 70004


  #     ID/EX Register Write
  #     --------------------
  #     Control: regWrite = 1, regDest = 1, memToReg = 0, memRead = 0, memWrite = 0, aLUSrc = 0, branch = 0, aLUOp = 2,
  #     writeReg_15_11 = 7  writeReg_20_16 = 6  readReg1Value = 105  readReg2Value = 106  sEOffset = X  function = 20  incrPC = 70004

  #     ID/EX Register Read
  #     --------------------
  #     control = 000000000


  #     EX/MEM Register Write
  #     --------------------
  #     control = 000000000

  #     EX/MEM Register Read
  #     --------------------
  #     control = 000000000


  #     MEM/WB Register Write
  #     --------------------
  #     control = 000000000

  #     MEM/WB Register Read
  #     --------------------
  #     control = 000000000
  def runthrough(instructions)
    @cycle_num += 1
    instructions.each do | instruction |
      ifStage(instruction)
      idStage
      exStage
      memStage
      wbStage
      printOutEverything
      copyWriteToRead
      @cycle_num += 1
    end
  end

  # ifStage: Instruction Fetch
  # Fetch the next instruction and write it to the write side of the IF/ID Register
  # @param instruction [String] a MIPS instruction in hex
  # @return [void]
  # @note If the IF/ID Register already has an incrPC value, then increase it by 4. Otherwise, take the starting address
  def ifStage(instruction)
    @IfIdRegister.write = { instruction: instruction }
    if @IfIdRegister.read[:incrPC]
      @IfIdRegister.write[:incrPC] = (@IfIdRegister.read[:incrPC].to_i(16) + 4).to_s(16)
    else
      @IfIdRegister.write[:incrPC] = (@starting_address.to_i(16) + 4).to_s(16)
    end
  end

  # idStage: Instruction Decode
  # Reads the instruction from the read side of the IF/ID Register, decodes it, and writes the results to the write side of the ID/EX Register.
  # @return [void]
  # @note Determines whether instruction is r-format or i-format and uses the relevant function to further decode instructions
  def idStage
    instruction = @IfIdRegister.read[:instruction]
    address = @IfIdRegister.read[:incrPC]
    if instruction.to_i(16) == 0
      # this is a noop
      @IdExRegister.write = {control: "000000000"}
    else
      # convert to binary
      binary_instr = sprintf("%b", instruction).rjust(32, '0')
      first_six = binary_instr[-32..-27].to_i(2)
      # determine if r or i, then decode
      if first_six == 0
        translate_r_format(binary_instr)
      else
        translate_i_format(binary_instr, address)
      end
      # regardless of type, add write/read values and incrPC
      @IdExRegister.write[:writeReg_15_11] = binary_instr[-16..-12].to_i(2)
      @IdExRegister.write[:writeReg_20_16] = binary_instr[-21..-17].to_i(2)
      @IdExRegister.write[:readReg1Value] = @regs.content[binary_instr[-26..-22].to_i(2)]
      @IdExRegister.write[:readReg2Value] = @regs.content[binary_instr[-21..-17].to_i(2)]
      @IdExRegister.write[:incrPC] = address if address
    end
  end

  # exStage: Execute
  # Performs the instruction from the read side of the ID/EX Register and writes the results to the write side of the ID/EX Register.
  # @return [void]
  def exStage
    # noop
    if @IdExRegister.read[:control] == "000000000"
      @ExMemRegister.write = {control: "000000000" }
    else
      # if this is the first one, set control to a hash
      if @ExMemRegister.write[:control] == "000000000"
        @ExMemRegister.write[:control] = {}
      end
      # copy control variables that need to go to Ex/Mem to Ex/Mem write
      @ExMemRegister.write[:control][:memWrite] = @IdExRegister.read[:control][:memWrite]
      @ExMemRegister.write[:control][:memRead] = @IdExRegister.read[:control][:memRead]
      @ExMemRegister.write[:control][:memToReg] = @IdExRegister.read[:control][:memToReg]
      @ExMemRegister.write[:control][:regWrite] = @IdExRegister.read[:control][:regWrite]
      @ExMemRegister.write[:control][:branch] = @IdExRegister.read[:control][:branch]
      @ExMemRegister.write[:incrPC] = @IdExRegister.read[:incrPC]
      # read in needed variables for later execution
      aLUSrc = @IdExRegister.read[:control][:aLUSrc]
      aLUOp = @IdExRegister.read[:control][:aLUOp]
      reg1 = @IdExRegister.read[:readReg1Value].to_i(16)
      reg2 = @IdExRegister.read[:readReg2Value].to_i(16)
      regDest = @IdExRegister.read[:control][:regDest]

      # if the first register, use 20-16
      # if the second, use 15-11
      # otherwise, it shouldn't be writing to a register, so don't care
      if regDest == 0
        @ExMemRegister.write[:writeRegNum] = @IdExRegister.read[:writeReg_20_16]
      elsif regDest == 1
        @ExMemRegister.write[:writeRegNum] = @IdExRegister.read[:writeReg_15_11]
      else
        @ExMemRegister.write[:writeRegNum] = "X"
      end

      # calculate ALUResult
      if @IdExRegister.read[:function] == "22"
        # sub
        aLUResult = (reg1 - reg2).to_s(16)
      elsif @IdExRegister.read[:function] == "20"
        # add
        aLUResult = (reg2 + reg1).to_s(16)
      else
        # lb & sb
        aLUResult = (reg1 + convert_to_signed_binary(@IdExRegister.read[:sEOffset].to_i(16).to_s(2))).to_s(16)
      end
      # this project is not handling branches
      @ExMemRegister.write[:calcBTA] = "X"
      @ExMemRegister.write[:zero] = "F"
      @ExMemRegister.write[:aLUResult] = aLUResult
      @ExMemRegister.write[:sWValue] = reg2.to_s(16)
    end
  end

  # memStage: Memory Access
  # If the instruction is a load, then we get the data from the address calculated in the Execute stage and store it in the register. If it is a store, then we store the result in main memory.
  # @return [void]
  def memStage
    # noop
    if @ExMemRegister.read[:control] == "000000000"
      @MemWbRegister.write = {control: "000000000" }
    else
      # if this is the first one, set control to a hash
      if @MemWbRegister.write[:control] == "000000000"
        @MemWbRegister.write[:control] = {}
      end
      memRead = @ExMemRegister.read[:control][:memRead]
      memWrite = @ExMemRegister.read[:control][:memWrite]
      if memRead == 1
        @MemWbRegister.write[:lWDataValue] = @mainMem.content[@ExMemRegister.read[:aLUResult].to_i(16)]
      elsif memWrite == 1
        @mainMem.content[@ExMemRegister.read[:aLUResult].to_i(16)] = @ExMemRegister.read[:sWValue]
      else
        @MemWbRegister.write[:lWDataValue] = "X"
      end
      @MemWbRegister.write[:aLUResult] = @ExMemRegister.read[:aLUResult]
      @MemWbRegister.write[:writeRegNum] = @ExMemRegister.read[:writeRegNum]
      @MemWbRegister.write[:control][:memToReg] = @ExMemRegister.read[:control][:memToReg]
      @MemWbRegister.write[:control][:regWrite] = @ExMemRegister.read[:control][:regWrite]
    end
  end

  # wbStage: Register Write Back
  # If writing to registers (add, sub, or load), then write the given value to the register.
  # @raise [ArgumentError] expected 1 or 0 for memToReg
  # @return [void]
  def wbStage
    return if @MemWbRegister.read[:control].is_a? String
    regWrite = @MemWbRegister.read[:control][:regWrite]
    memToReg = @MemWbRegister.read[:control][:memToReg]
    if regWrite == 1
      if memToReg == 1
        @regs.content[@MemWbRegister.read[:writeRegNum]] = @MemWbRegister.read[:lWDataValue]
      elsif memToReg == 0
        @regs.content[@MemWbRegister.read[:writeRegNum]] = @MemWbRegister.read[:aLUResult]
      else
        raise ArgumentError.new("Expecting 1 or 0 for memToReg. Got #{memToReg}.")
      end
    end
  end

  # Prints out current clock cycle, registers, and all contents of the pipeline registers.
  # @return [void]
  def printOutEverything
    puts "-----------------"
    puts "| Clock Cycle #{@cycle_num} |"
    puts "-----------------"
    @regs.show
    puts ""
    puts ""
    [@IfIdRegister, @IdExRegister, @ExMemRegister, @MemWbRegister].each do |register|
      [:write, :read].each do |side|
        puts register.title + " " + side.to_s.capitalize
        puts "--------------------"
        other_keys = ""
        # for each side, get the keys and values
        register.send(side).each do |key, value|
          # if it is the control hash
          if value.is_a?(Hash)
            control = key.to_s.capitalize + ": "
            value.each do |key, value|
              control += key.to_s + " = " + value.to_s + ", "
            end
            puts control
          # otherwise, it's just normal contents
          else
            other_keys += key.to_s + " = " + value.to_s + "  "
          end
        end
        puts other_keys
        puts ""
      end
      puts ""
    end
  end

  # Copies the write side of each PipelineRegister to the read side of that register.
  # @return [void]
  # @note So it doesn't use the exact same hash object, we use #clone to copy from write to read.
  def copyWriteToRead
    [@IfIdRegister, @IdExRegister, @ExMemRegister, @MemWbRegister].each do |register|
      register.read = register.write.clone
      register.read[:control] = register.write[:control].clone if register.write[:control]
    end
  end

  # This is the class that creates the simulated main memory
  #
  # Initialization:
  #   main_memory = PipelineSim::MainMem.new(size)
  #   After initialization, @content is the only thing that can be changed
  #
  # Definition of parameters:
  #   size: integer, reflects the total size of main memory array
  class MainMem
    # Returns the content of the cache
    # @return [Array] array of strings representing current data in the cache
    attr_accessor :content
    # Initializes new MainMemory object
    # @param size [Integer] reflects the total size of main memory array
    # @return [MainMemory] new MainMemory object
    # @note This function just creates dummy data in the main memory.
    #   Currently it fills it with hexadecimal numbers.
    def initialize(size)
      @content = initialize_content(size)
    end

    private
    # since this is built to be a simulation, main memory should just be filled with
    # hex values from 0 to FF, then repeated until full.
    def initialize_content(size)
      content = []
      num = 0
      (0..size).each do
        num = 0 if (num != 0 && num % 256 == 0)
        content << num.to_s(16)
        num+=1
      end
      content
    end
  end

  # This is the class that creates the simulated registers
  #
  # Initialization:
  #   regs = Regs.new(size)
  #   After initialization, @content is the only thing that can be changed
  #
  # Definition of parameters:
  #   size: integer, reflects the total size of register array
  class Regs
    # Returns the content of the register
    # @return [Array] array of strings representing current data in the register
    attr_accessor :content
    # Initializes new Regs object
    # @param size [Integer] reflects the total size of register array
    # @return [Regs] new Regs object
    # @note This function just creates dummy data in the registers.
    #   Currently it fills it with hexadecimal numbers.
    def initialize(size)
      @content = initialize_content(size)
    end

    # Prints out contents of the register
    # @return [void]
    def show
      puts "Regs: " + @content.join(', ')
    end

    private
    def initialize_content(size)
      content = [0]
      num = "100".to_i(16)
      (1..size).each do |i|
        content << (num + i).to_s(16)
      end
      content
    end
  end

  # This is the class that creates the simulated pipeline registers
  #
  # Initialization:
  #   @IfIdRegister = PipelineRegister.new("IF/ID Register", {instruction: "0x00000000"})
  #   After initialization, both @read and @write can be updated, but not @title
  #
  # Definition of parameters:
  #   title: string, name of register
  #   read: hash, contents of the read side
  #   write: hash, contents of the write side
  class PipelineRegister
    # Returns the title of the register
    # @return [String] title of the register
    attr_reader :title
    # Returns the content of the read side of the register
    # @return [Hash] hash representing the contents of the read side
    attr_accessor :read
    # Returns the content of the write side of the register
    # @return [Hash] hash representing the contents of the write side
    attr_accessor :write
    # Initializes new pipeline register object
    # @param title [String] name of register
    # @param hash [Hash] the initialization value of the register's read/write sides
    # @return [PipelineRegister] new PipelineRegister object
    def initialize(title, hash)
      @title = title
      @read = hash
      @write = hash
    end
  end

  private
  # # an abbreviated list of opcode/function codes
  FUNCTIONS = {"100000" => "add",
               "100010" => "sub"}

  OPCODES = {"000100" => "beq",
             "000101" => "bne",
             "100011" => "lw",
             "100000" => "lb",
             "101011" => "sw",
             "101000" => "sb" }

  # translating i format (almost the same function as MIPs project)
  def translate_i_format(binary, address)
    offset = binary[-16..-1]
    instruction = OPCODES[binary[-32..-27]]
    # set control variables depending on instruction
    if instruction == "lb" || instruction == "lw"
      @IdExRegister.write[:control] = {regWrite: 1, regDest: 0, memToReg: 1, memRead: 1, memWrite: 0, aLUSrc: 1, branch: 0}
    elsif instruction == "sb" || instruction == "sw"
      @IdExRegister.write[:control] = {regWrite: 0, regDest: "X", memToReg: "X", memRead: 0, memWrite: 1, aLUSrc: 1, branch: 0}
    elsif instruction == "beq" || instruction == "bne"
      @IdExRegister.write[:control] = {regWrite: 0, regDest: "X", memToReg: "X", memRead: 0, memWrite: 0, aLUSrc: 0, branch: 1}
    else
      # raise error if I forgot to include the instruction in the list of opcodes
      raise ArgumentError.new("Expecting argument to exist in list of opcodes. Got #{instruction}.")
    end
    @IdExRegister.write[:control][:aLUOp] = 0
    @IdExRegister.write[:sEOffset] = offset.to_i(2).to_s(16)
    @IdExRegister.write[:function] = "X"
  end

  # translating r format (almost the same function as MIPs project)
  def translate_r_format(binary)
    instruction = binary[-6..-1]
    # set control variables
    @IdExRegister.write[:control] = {regWrite: 1, regDest: 1, memToReg: 0, memRead: 0, memWrite: 0, aLUSrc: 0, branch: 0, aLUOp: 2}
    @IdExRegister.write[:sEOffset] = "X"
    @IdExRegister.write[:function] = instruction.to_i(2).to_s(16)
  end

  # while this could be done in other languages by casting the variable as a short,
  # ruby does not have a short integer type, so converted using two's complement
  def convert_to_signed_binary(binary)
    binary_int = binary.to_i(2)
    if binary_int >= 2**15
      return binary_int - 2**16
    else
      return binary_int
    end
  end
end

instructions = ["0xa1020000", "0x810AFFFC", "0x00831820", "0x01263820", "0x01224820", "0x81180000", "0x81510010", "0x00624022", "0x00000000", "0x00000000", "0x00000000", "0x00000000"]
simulation = PipelineSim.new("0x70000")
simulation.runthrough(instructions)