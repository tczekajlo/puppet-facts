# managed by puppet
require 'facter'

class BlockInfo
  attr_accessor :device

  def initialize(device)
    @device = device
  end

  def statepath
    return "/sys/block/" + @device.sub(/_/, "!") + "/stat"
  end

  def io_state
    return @state if @state
    iostate = File.read(statepath).rstrip
    raise "state for device #{device} not found" unless iostate
    @state = iostate.gsub(/\s+/m, ' ').strip.split(" ")[8]
  end
end

def discover_blockdevs
  bdevs = []
  Dir.glob("/sys/block/sd?") do |path|
    bdevs << BlockInfo.new(path[/sd./])
  end
  Dir.glob("/sys/block/vd?") do |path|
    bdevs << BlockInfo.new(path[/vd./])
  end
  Dir.glob("/sys/block/xvd?") do |path|
    bdevs << BlockInfo.new(path[/xvd./])
  end
  return bdevs
end

if Facter.value(:kernel) == "Linux"
    blockdevs = []
    Facter.debug "Calling discover_blockdevs"
    discover_blockdevs().each do |device|
    begin
        Facter.debug "Running for device #{device.device}"
        blockdevs << device
    end
    end
end

Facter.add(:io_in_flight) do
  setcode do
    devices = {}
    blockdevs.each do |device|
        devices[device.device] = device.io_state
    end
    devices
  end
end

