#!/usr/bin/env ruby
#
# Copyright 2013 FunGo Studios (team@fungostudios.com)
#
# Depends on librato-metrics gem
# gem install librato-metrics
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require "net/http"
require "uri"

class YohoushiMetrics < Sensu::Handler
  REGEXP = /^(?<key>.+?)\t+(?<value>.+?)\t+(?<timestamp>.+?)$/

  # override filters from Sensu::Handler. not appropriate for metric handlers
  def filter
  end

  def handle
    @event['check']['output'].split("\n").each do |line|
      matches = REGEXP.match(line)
      begin
        timeout(3) do
          if matches
            Net::HTTP.start(settings['yohoushi']['host'], settings['yohoushi']['port']){|http|
              body = "number=#{matches[:value]}"
              response = http.post(settings['yohoushi']['endpoint'] + matches[:key], body)
            }
          end
        end
      rescue Timeout::Error
        puts "yohoushi -- timed out while sending metrics"
      rescue => error
        puts "yohoushi -- failed to send metrics : #{error.message}"
        puts "  #{error.backtrace.join("\n\t")}"
      end
    end
  end
end
