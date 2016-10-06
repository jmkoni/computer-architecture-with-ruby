require 'fileutils'
class MipsDisassembler
  # This class disassembles instructions from hex or binary to human readable Mips
  # Initialization: MipsTranslator.new(array_of_instructions, starting_address, is_hex)
  # Definition of parameters:
  #     array_of_instructions: an array of instructions in hex or binary.
  #                            Will generally be strings.
  #     starting_address: whatever address you want the instructions to start at
  #     is_hex: true or false, depending on whether or not the instructions are hex or not
  #             true if hex, false if binary
  #
  # Example:
  # > array_of_hex = ["0x022DA822",
  #                   "0x8EF30018",
  #                   "0x12A70004",
  #                   "0x02689820",
  #                   "0xAD930018",
  #                   "0x02697824",
  #                   "0xAD8FFFF4",
  #                   "0x018C6020",
  #                   "0x02A4A825",
  #                   "0x158FFFF6",
  #                   "0x8E59FFF0"]
  #
  # > mips = MipsDisassembler.new(array_of_hex, "7A060", true)
  # > results = mips.disassemble
  # > results.each { |instruction| puts instruction }
  #
  # Output:
  # 7A060 sub $21 $17 $13
  # 7a064 lw $19, 24 ($23)
  # 7a068 beq $7, $21, address 0x7a07c
  # 7a06c add $19 $19 $8
  # 7a070 sw $19, 24 ($12)
  # 7a074 and $15 $19 $9
  # 7a078 sw $15, -12 ($12)
  # 7a07c add $12 $12 $12
  # 7a080 or $21 $21 $4
  # 7a084 bne $15, $12, address 0xba060
  # 7a088 lw $25, -16 ($18)

  def initialize(array_of_instructions, starting_address, is_hex)
    @instructions = array_of_instructions
    @starting_address = starting_address
    @is_hex = is_hex
  end

  def disassemble
    disassemble_instructions(@instructions, @starting_address, @is_hex)
  end

  # write MIPs instructions to file mips_results.txt
  def output_to_file
    File.open("mips_results.txt", "w") do |f|
      in_file = ""
      disassemble.each { |instruction| in_file << instruction + "\n" }
      f.write(in_file)
    end
  end

  private
  # an abbreviated list of opcode to MIPS function translations
  INSTRUCTIONS = {"000100" => "beq",
                  "000101" => "bne",
                  "011000" => "mult",
                  "011010" => "div",
                  "100000" => "add",
                  "100010" => "sub",
                  "100011" => "lw",
                  "100100" => "and",
                  "100101" => "or",
                  "100110" => "xor",
                  "101011" => "sw" }

  # takes an array of hex and returns an array of binary (32bit, including leading zeros)
  def translate_to_binary(array_of_hex)
    array_of_binary = []
    array_of_hex.each do |num|
      array_of_binary << sprintf("%b", num).rjust(32, '0')
    end
    array_of_binary
  end

  # take binary/hex instructions and starting address and return an array of MIPs instructions
  # determines if r-format or i-format and parses accordingly
  def disassemble_instructions(instructions, starting_address, is_hex)
    array_of_binary = is_hex ? translate_to_binary(instructions) : instructions
    array_of_instructions = []
    address = starting_address
    array_of_binary.each do |binary|
      first_six = binary[-32..-27].to_i(2)
      if first_six == 0
        instruction_text = translate_r_format(binary)
      else
        instruction_text = translate_i_format(binary, address)
      end
      array_of_instructions << address + " " + instruction_text
      # increase address to the next spot
      address = (address.to_i(16) + 4).to_s(16)
    end
    array_of_instructions
  end

  def translate_i_format(binary, address)
    offset = binary[-16..-1]
    sd = binary[-21..-17].to_i(2)
    s1 = binary[-26..-22].to_i(2)
    instruction = INSTRUCTIONS[binary[-32..-27]]
    if instruction == "sw" || instruction == "lw"
      # only if sw or lw should offset be converted to signed binary
      offset = convert_to_signed_binary(offset)
      return "#{instruction} $#{sd}, #{offset} ($#{s1})"
    else
      # offset must be right adjusted by 2 0's, added four (to adjust for counting from
      # the next address) and then added to the current address
      # end result should show in hex format
      offset = "0x#{(address.to_i(16) + (offset + "00").to_i(2)+4).to_s(16).rjust(4, "0")}"
      return "#{instruction} $#{sd}, $#{s1}, address #{offset}"
    end
  end

  def translate_r_format(binary)
    instruction = binary[-6..-1]
    ds = binary[-16..-12].to_i(2)
    s2 = binary[-21..-17].to_i(2)
    s1 = binary[-26..-22].to_i(2)
    return "#{INSTRUCTIONS[instruction]} $#{ds} $#{s1} $#{s2}"
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

# here is sample data
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
mips.output_to_file
