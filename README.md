# Computer Architecture... with Ruby
While learning more about computer architecture, I wrote some Ruby scripts:

* MIPS Disassembler - a program that takes an array of hex or binary and translates it into MIPS instructions
* Cache Simulation - a program that takes an array or instructions, addresses, and data and updates a simulated cache. Could be altered to take user input.
* Pipeline Simulation - a program that takes an array of instructions and passes them through each step of a simulated pipeline, updating the registers on each.

View full docs at: https://jmkoni.github.io/computer-architecture-with-ruby

View source code at: https://github.com/jmkoni/computer-architecture-with-ruby

***

### MIPS Disassembler
This class disassembles instructions from hex or binary to human readable Mips
####Initialization:
```ruby
MipsDisassember.new(array_of_instructions, starting_address, is_hex)
```
####Definition of parameters:

* array_of_instructions: an array of instructions in hex or binary. Will generally be strings.
* starting_address: whatever address you want the instructions to start at
* is_hex: true or false, depending on whether or not the instructions are hex or not true if hex, false if binary

####Example:
```ruby
array_of_hex = ["0x022DA822",
                "0x8EF30018",
                "0x12A70004",
                "0x02689820",
                "0xAD930018",
                "0x02697824",
                "0xAD8FFFF4",
                "0x018C6020",
                "0x02A4A825",
                "0x158FFFF6",
                "0x8E59FFF0"]

mips = MipsDisassembler.new(array_of_hex, "7A060", true)
results = mips.disassemble
results.each { |instruction| puts instruction }
```

####Output:
```
    7A060 sub $21 $17 $13
    7a064 lw $19, 24 ($23)
    7a068 beq $7, $21, address 0x7a07c
    7a06c add $19 $19 $8
    7a070 sw $19, 24 ($12)
    7a074 and $15 $19 $9
    7a078 sw $15, -12 ($12)
    7a07c add $12 $12 $12
    7a080 or $21 $21 $4
    7a084 bne $15, $12, address 0xba060
    7a088 lw $25, -16 ($18)
```

***

### Cache Simulation
This class creates a simulation of a cache. Currently it is built to
take in an array of actions. It could easily be rewritten to take in user
input instead.

####Initialization:
```ruby
cache = CacheSim::Cache.new(size)
```

####Definition of parameters:

* size: integer, reflects the number and size of slots. Ex. with this one, there are 16 slots and each slot has space for 16 pieces of data
* operations: a list of operations Ex: ["R", "4C3", "D", "W", "14C", "99"]

####Example####
```ruby
cache = CacheSim::Cache.new(16)
cache.perform_actions(["R", "4C3", "D", "W", "14C", "99"])
```

####Output####
```
    (R)ead, (W)rite, or (D)isplay cache?
    R
    What address would you like read?
    4C3
    At that byte, there is the value c3 (Cache miss)
    (R)ead, (W)rite, or (D)isplay cache?
    D
    Slot | Valid | Tag | Data
      0  |   1   |  0  | 0 1 2 3 4 5 6 7 8 9 a b c d e f
      1  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      2  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      3  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      4  |   1   |  1  | 40 41 42 43 44 45 46 47 48 49 4a 4b 4c 4d 4e 4f
      5  |   1   |  1  | 50 51 52 53 54 55 56 57 58 59 5a 5b 5c 5d 5e 5f
      6  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      7  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      8  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      9  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      a  |   1   |  3  | a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 aa ab ac ad ae af
      b  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      c  |   1   |  4  | c0 c1 c2 c3 c4 c5 c6 c7 c8 c9 ca cb cc cd ce cf
      d  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      e  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      f  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    (R)ead, (W)rite, or (D)isplay cache?
    W
    What address would you like to write to?
    14C
    What data would you like to write at that address?
    99
```

***

### Pipeline Simulation
This class creates a simulation of a pipeline.

####Initialization:
```ruby
simulation = PipelineSim.new(starting_address)
simulation.runthrough(instructions)
```

####Definition of parameters:
* starting_address: starting address of the first instruction (in hex)
* instructions: array of mips instructions, in hex

####Example####
```ruby
instructions = ["0x00a63820",
                "0x8d0f0004",
                "0xad09fffc",
                "0x00625022",
                "0x00000000",
                "0x00000000",
                "0x00000000",
                "0x00000000"]
simulation = PipelineSim.new("0x70000")
simulation.runthrough(instructions)
```

####Output####
```
    -----------------
    | Clock Cycle 1 |
    -----------------
    Regs: 0, 101, 102, 103, 104, 105, 106, 107, 108, 109, 10a, 10b, 10c, 10d, 10e, 10f, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 11a, 11b, 11c, 11d, 11e, 11f, 120


    IF/ID Register Write
    --------------------
    instruction = 0xa1020000  incrPC = 70004

    IF/ID Register Read
    --------------------
    instruction = 0x00000000


    ID/EX Register Write
    --------------------
    control = 000000000

    ID/EX Register Read
    --------------------
    control = 000000000


    EX/MEM Register Write
    --------------------
    control = 000000000

    EX/MEM Register Read
    --------------------
    control = 000000000


    MEM/WB Register Write
    --------------------
    control = 000000000

    MEM/WB Register Read
    --------------------
    control = 000000000


    -----------------
    | Clock Cycle 2 |
    -----------------
    Regs: 0, 101, 102, 103, 104, 105, 106, 107, 108, 109, 10a, 10b, 10c, 10d, 10e, 10f, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 11a, 11b, 11c, 11d, 11e, 11f, 120


    IF/ID Register Write
    --------------------
    instruction = 0x810AFFFC  incrPC = 70008

    IF/ID Register Read
    --------------------
    instruction = 0xa1020000  incrPC = 70004


    ID/EX Register Write
    --------------------
    Control: regWrite = 0, regDest = X, memToReg = X, memRead = 0, memWrite = 1, aLUSrc = 1, branch = 0, aLUOp = 0,
    sEOffset = 0  function = X  writeReg_15_11 = 0  writeReg_20_16 = 2  readReg1Value = 108  readReg2Value = 102  incrPC = 70004

    ID/EX Register Read
    --------------------
    control = 000000000


    EX/MEM Register Write
    --------------------
    control = 000000000

    EX/MEM Register Read
    --------------------
    control = 000000000


    MEM/WB Register Write
    --------------------
    control = 000000000

    MEM/WB Register Read
    --------------------
    control = 000000000
```
