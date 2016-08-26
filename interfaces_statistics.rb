require 'facter'
require 'facter/util/ip'

class NetInfo
  attr_accessor :device

  def initialize(device)
    @device = device
  end

  def statepath
    return "/sys/class/net/" + @device.sub(/_/, "!") + "/statistics"
  end

  def net_tx
    return @state_tx if @state_tx
    iostate_tx = File.read(statepath+"/tx_bytes").rstrip
    raise "state for device #{device} not found" unless iostate_tx
    @state_tx = iostate_tx
  end

  def net_rx
    return @state_rx if @state_rx
    iostate_rx = File.read(statepath+"/rx_bytes").rstrip
    raise "state for device #{device} not found" unless iostate_rx
    @state_rx = iostate_rx
  end
end

Facter.add(:interfaces_statistics) do
  if Facter.value(:kernel) == "Linux"
    setcode do
      ifaces = {}
      Facter::Util::IP.get_interfaces.each do |interface|
          netdev = NetInfo.new(interface)
          details = {}
          details['tx_bytes'] = netdev.net_tx
          details['rx_bytes'] = netdev.net_rx
          details.reject! {|k,v| v.nil? || v.to_s.empty? }
          ifaces[interface] = details
      end
      ifaces
    end
  end
end
