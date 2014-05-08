#!/usr/bin/env ruby
#
# Network interface throughput
# ===
#
# DEPENDENCIES:
#   sensu-plugin Ruby gem
#   sysstat to get 'sar'
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'
require 'socket'

class NetIFMetrics < Sensu::Plugin::Metric::CLI::Graphite

  option :scheme,
    :description => "Metric naming scheme, text to prepend to .$parent.$child",
    :long => "--scheme SCHEME",
    :default => "/#{Socket.gethostname}/netif"

  def run
    `sar -n DEV 1 1 | grep Average | grep -v IFACE`.each_line do |line|
      stats = line.split(/\s+/)
      unless stats.empty?
        stats.shift
        nic = stats.shift
        output "#{config[:scheme]}/#{nic}/rx_pps", stats[0].to_f.round if stats[0]
        output "#{config[:scheme]}/#{nic}/tx_pps", stats[1].to_f.round if stats[1]
        output "#{config[:scheme]}/#{nic}/rx_bps", stats[2].to_f.round * 8 * 1024 if stats[2]
        output "#{config[:scheme]}/#{nic}/tx_bps", stats[3].to_f.round * 8 * 1024 if stats[3]
      end
    end

    ok

  end

end
