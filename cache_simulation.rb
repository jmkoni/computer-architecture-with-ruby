# @author Jennifer Konikowski <jmkoni@icloud.com>
# This class creates a simulation of a cache. Currently it is built to
# take in an array of actions. It could easily be rewritten to take in user
# input instead.
#
# Initialization:
#     cache = CacheSim::Cache.new(size)
#     cache.perform_actions(operations)
#
# Definition of parameters:
#     size:       integer, reflects the number and size of slots.
#                 Ex. with this one, there are 16 slots and each
#                     slot has space for 16 pieces of data
#     operations: a list of operations
#                 Ex: ["R", "4C3", "D", "W", "14C", "99"]
class CacheSim
  # This class creates the slots.
  # Initialization:
  #     slot = CacheSim::Slot.new(num, is_dirty, is_valid, tag, saved_blocks)
  class Slot
    # Gets the current slot number
    # @return [String] hexadecimal slot number
    attr_reader :num
    # Returns whether a slot currently has valid content or not
    # @return [Boolean] 1 if valid, 0 otherwise
    attr_accessor :is_valid
    # Returns whether a slot currently is dirty (has content not copied to main memory)
    # @return [Boolean] 1 if dirty, 0 otherwise
    attr_accessor :is_dirty
    # Returns current hexadecimal tag in the slot
    # @return [String] hexadecimal tag number
    attr_accessor :tag
    # Returns array of saved blocks. Defaults to array of zeros if empty.
    # @return [Array] array of blocks currently in cache
    attr_accessor :saved_blocks


    # Initalizes new Slot object
    # @param num [String] slot number, doesn't change after initialization, hexadecimal
    # @param is_dirty [Boolean] flag to check if slot is dirty. 1 if dirty, 0 otherwise
    # @param is_valid [Boolean] flag to check if slot has valid data. 1 if valid, 0 otherwise
    # @param tag [String] current tag saved in slot
    # @param saved_blocks [Array] array of blocks currently saved in the cache
    # @note Generally you will want to initialize slots as empty. See the example.
    # @return [Slot] a new Slot object
    # @example Create a new slot
    #     Slot.new("1a", 0, 0, 0, [0, 0, 0, 0])
    def initialize(num, is_dirty, is_valid, tag, saved_blocks)
      @num = num
      @is_dirty = is_dirty
      @is_valid = is_valid
      @tag = tag
      @saved_blocks = saved_blocks
    end
  end

  # This is the class that creates the actual cache and performs most of the actions.
  #
  # Initialization:
  #   cache = CacheSim::Cache.new(size)
  #
  # MainMemory is initialized here and, while the contents can be changed,
  # @main_memory itself cannot. Ex. I cannot create a brand new instance of
  # @main_memory once the cache is initialized
  class Cache
    # Returns size of cache
    # @return [Integer] number of slots in cache (and length of each slot array)
    attr_accessor :size
    # Returns an array of slots
    # @return [Array] array of slots
    attr_accessor :slots
    # Retrieves current contents of main memory
    # @return [MainMemory] current main memory
    attr_reader :main_memory
    # Initializes new Cache object
    # @param size [Integer] reflects the number and size of slots.
    # @example Create a new cache
    #     cache = CacheSim::Cache.new(16)
    # @return [Cache] new Cache object
    # @note With this example, there are 16 slots and each slot has space for 16 pieces of data
    def initialize(size)
      @size = size
      @slots = initialize_slots
      @main_memory = CacheSim::MainMemory.new(8*(@size**2)-1)
    end

    # Takes an array of operations and performs them on the cache
    # @param op [Array] an array of strings representing operations on the cache.
    #   Actions are R, W, and D, and each of the actions must be followed
    #   by the correct value or address.
    # @raise [ArgumentError] expected a D, W, or R and got something else
    # @return [void]
    # @note This function prints out the cache as it goes along
    # @todo This function could be redone to take user input instead
    # @example Given an example array of operations
    #     cache.perform_actions(["R", "4C3", "D", "W", "14C", "99"])
    #     => to screen:
    #     (R)ead, (W)rite, or (D)isplay cache?
    #     R
    #     What address would you like read?
    #     4C3
    #     At that byte, there is the value c3 (Cache miss)
    #     (R)ead, (W)rite, or (D)isplay cache?
    #     D
    #     Slot | Valid | Tag | Data
    #       0  |   1   |  0  | 0 1 2 3 4 5 6 7 8 9 a b c d e f
    #       1  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    #       2  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    #       3  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    #       4  |   1   |  1  | 40 41 42 43 44 45 46 47 48 49 4a 4b 4c 4d 4e 4f
    #       5  |   1   |  1  | 50 51 52 53 54 55 56 57 58 59 5a 5b 5c 5d 5e 5f
    #       6  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    #       7  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    #       8  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    #       9  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    #       a  |   1   |  3  | a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 aa ab ac ad ae af
    #       b  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    #       c  |   1   |  4  | c0 c1 c2 c3 c4 c5 c6 c7 c8 c9 ca cb cc cd ce cf
    #       d  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    #       e  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    #       f  |   0   |  0  | 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    #     (R)ead, (W)rite, or (D)isplay cache?
    #     W
    #     What address would you like to write to?
    #     14C
    #     What data would you like to write at that address?
    #     99
    def perform_actions(op)
      i = 0
      while i < op.length
        get_action(op[i])
        if op[i] == "D"
          display_cache
          i+=1
        elsif op[i] == "R"
          display_read(op[i+1])
          i+=2
        elsif op[i] == "W"
          display_write(op[i+1], op[i+2])
          i+=3
        else
          # added in as a double check in case I got off track
          # if user input, would be a check to the user that they didn't
          # enter a D, R, or W
          raise ArgumentError.new("Expecting a D, R, or W at this point. Got #{op[i]}.")
        end
      end
    end

    # Takes an address and data, prints out the actions you are taking, determines if
    # it's a hit or a miss, then writes that data to the cache.
    # @param address [String] address that the data should be written to
    # @param data [String] data to be written to cache
    # @return [void]
    def display_write(address, data)
      puts "What address would you like to write to?"
      puts address
      puts "What data would you like to write at that address?"
      puts data
      hit_miss = write(address, data)
      puts "Value #{data} has been written to address #{address} (Cache #{hit_miss})"
    end

    # Takes an address, prints out the actions you are taking, determines if
    # it's a hit or a miss, then reads the data from the cache.
    # @param address [String] address that we want to read from
    # @return [void]
    def display_read(address)
      puts "What address would you like read?"
      puts address
      value, hit_miss = read(address)
      puts "At that byte, there is the value #{value} (Cache #{hit_miss})"
    end

    # Displays the cache in it's current state
    # @return [void]
    def display_cache
      puts "Slot | Valid | Tag | Data "
      @slots.each do |slot|
        puts "  #{slot.num}  |   #{slot.is_valid}   |  #{slot.tag}  | #{slot.saved_blocks.join(" ")}"
      end
    end

    private
    # slots are initialized essentially as a @size x @size hash, with @size number of slots
    # and each slot has @size number of spots for data
    def initialize_slots
      slots = []
      (0..(@size-1)).each do |i|
        slots << Slot.new(i.to_s(16), 0, 0, 0, Array.new(@size, 0))
      end
      slots
    end

    def get_action(operation)
      puts "(R)ead, (W)rite, or (D)isplay cache?" if ["R", "W", "D"].include? operation
      puts operation
    end

    # called whenever we need to write to a slot
    # this function first checks if a slot is dirty
    # if it is, then it writes the contents to main memory first
    def write_to_slot(slot, tag, blocks)
      if slot.is_dirty == 1
        write_to_main_memory(slot)
      end
      slot.is_valid = 1
      slot.tag = tag
      slot.saved_blocks = blocks
    end

    # writes contents of slot to appropriate spot in main memory
    # starts off with the block start address (tag + slot_num + 0)
    # since ruby treats hex as string, it has to be converted to integer
    # to determine the actual index of the main memory array that we are starting in
    # Then we just go through each of the saved blocks in the slot and write them to MM
    # the slot's is_dirty field must then be set back to 0, since the data from
    # the slot is now in-sync with main memory.
    def write_to_main_memory(slot)
      block_start_address = slot.tag + slot.num + "0"
      block_address = block_start_address.to_i(16)
      slot.saved_blocks.each do |block|
        @main_memory.content[block_address] = block
        block_address += 1
      end
      slot.is_dirty = 0
    end

    # reads data from the cache
    # if data desired is not already in the cache, writes data to appropriate slot
    def read(address)
      tag, slot_num, block_offset = split_address(address)
      slot = @slots[slot_num.to_i(16)]
      hit_miss = hit_miss(slot, tag)
      if hit_miss == "hit"
        value = slot.saved_blocks[block_offset.to_i(16)]
      else
        value = @main_memory.content[address.to_i(16)]
        range = (tag + slot_num + "0").to_i(16)..(tag + slot_num + "F").to_i(16)
        write_to_slot(slot, tag, @main_memory.content[range])
      end
      return value, hit_miss
    end

    # determines if it is a hit or a miss
    def hit_miss(slot, tag)
      if slot.tag == tag and slot.is_valid == 1
        return "hit"
      else
        return "miss"
      end
    end

    # splits up address into tag, slot_num, and block_offset
    def split_address(address)
      address = address.rjust(3, "0")
      tag = address[0]
      slot_num = address[1]
      block_offset = address[2]
      return [tag, slot_num, block_offset]
    end

    # given address & data, writes data to cache
    def write(address, data)
      tag, slot_num, block_offset = split_address(address)
      slot = @slots[slot_num.to_i(16)]
      hit_miss = hit_miss(slot, tag)
      if hit_miss == "miss"
        range = (tag + slot_num + "0").to_i(16)..(tag + slot_num + "F").to_i(16)
        write_to_slot(slot, tag, @main_memory.content[range])
      end
      slot.saved_blocks[block_offset.to_i(16)] = data
      slot.is_dirty = 1
      return hit_miss
    end
  end

  # This is the class that creates the simulated main memory
  #
  # Initialization:
  #     main_memory = CacheSim::MainMemory.new(size)
  #
  # After initialization, @content is the only thing that can be changed
  class MainMemory
    # Returns the content of the cache
    # @return [Array] array of strings representing current data in the cache
    attr_accessor :content
    # Initializes new MainMemory object
    # @param size [Integer] reflects the total size of main memory array
    # @return [MainMemory] new MainMemory object
    # @note This function just creates dummy data in the cache.
    #   Currently it fills it with hexadecimal numbers.
    def initialize(size)
      @size = size
      @content = initialize_content
    end

    private
    # since this is built to be a simulation, main memory should just be filled with
    # hex values from 0 to FF, then repeated until full.
    def initialize_content
      content = []
      num = 0
      (0..@size).each do
        num = 0 if (num != 0 && num % ((@size+1)/8) == 0)
        content << num.to_s(16)
        num+=1
      end
      content
    end
  end
end

operations = ["R", "5", "R", "6", "R", "7", "R", "14c",
  "R", "14e", "R", "14f", "R", "150", "R", "151", "R",
  "3A6", "R", "4C3", "D", "W", "14C", "99", "W", "63B",
  "7", "R", "582", "D", "R", "348", "R", "3F", "D", "R",
  "14b", "R", "14c", "R", "63F", "R", "83", "D"]

cache = CacheSim::Cache.new(16)
cache.perform_actions(operations)