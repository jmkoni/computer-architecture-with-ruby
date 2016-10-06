class CacheSim
  class Slot
    attr_accessor :num, :is_valid, :tag, :saved_blocks
    def initialize(num, is_valid, tag, saved_blocks)
      @num = num
      @is_valid = is_valid
      @tag = tag
      @saved_blocks = saved_blocks
    end
  end

  class Cache
    attr_accessor :size, :slots
    attr_reader :main_memory

    def initialize(size)
      @size = size
      @slots = initialize_slots
      @main_memory = CacheSim::MainMemory.new("7FF".to_i(16))
    end

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
          puts "OH NOOOOS"
        end
      end
    end

    def display_write(address, data)
      puts "What address would you like to write to?"
      puts address
      puts "What data would you like to write at that address?"
      puts data
      hit_miss = write(address, data)
      puts "Value #{data} has been written to address #{address} (Cache #{hit_miss})"
    end

    def display_read(address)
      puts "What address would you like read?"
      puts address
      value, hit_miss = read(address)
      puts "At that byte, there is the value #{value} (Cache #{hit_miss})"
    end

    def display_cache
      puts "Slot | Valid | Tag | Data "
      @slots.each do |slot|
        puts "  #{slot.num}  |   #{slot.is_valid}   |  #{slot.tag}  | #{slot.saved_blocks.join(" ")}"
      end
    end

    private
    def initialize_slots
      slots = []
      (0..(@size-1)).each do |i|
        slots << Slot.new(i.to_s(16), 0, 0, Array.new(16, 0))
      end
      slots
    end

    def get_action(operation)
      puts "(R)ead, (W)rite, or (D)isplay cache?" if ["R", "W", "D"].include? operation
      puts operation
    end

    def write_to_slot(slot, tag, blocks)
      slot.is_valid = 1
      slot.tag = tag
      slot.saved_blocks = blocks
    end

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

    def hit_miss(slot, tag)
      if slot.tag == tag and slot.is_valid == 1
        return "hit"
      else
        return "miss"
      end
    end

    def split_address(address)
      address = address.rjust(3, "0")
      tag = address[0]
      slot_num = address[1]
      block_offset = address[2]
      return [tag, slot_num, block_offset]
    end

    def write(address, data)
      tag, slot_num, block_offset = split_address(address)
      slot = @slots[slot_num.to_i(16)]
      hit_miss = hit_miss(slot, tag)
      if hit_miss == "miss"
        range = (tag + slot_num + "0").to_i(16)..(tag + slot_num + "F").to_i(16)
        write_to_slot(slot, tag, @main_memory.content[range])
      end
      slot.saved_blocks[block_offset.to_i(16)] = data
      return hit_miss
    end
  end

  class MainMemory
    attr_reader :content
    def initialize(size)
      @size = size
      @content = initialize_content
    end

    private
    def initialize_content
      content = []
      num = 0
      (0..@size).each do
        num = 0 if (num != 0 && num % 256 == 0)
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