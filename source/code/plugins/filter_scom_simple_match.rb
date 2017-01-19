module Fluent
  class SCOMSimpleMatchFilter < Filter
    
    Fluent::Plugin.register_filter('scom_simple_match', self)
    
    def initialize
      super
      require_relative 'scom_common'
    end
    
    REGEXP_MAX_NUM = 20
    
    (1..REGEXP_MAX_NUM).each {|i| config_param :"regexp#{i}", :string, :default => nil}
    (1..REGEXP_MAX_NUM).each {|i| config_param :"event_id#{i}", :string, :default => nil}
    (1..REGEXP_MAX_NUM).each {|i| config_param :"event_desc#{i}", :string, :default => nil}
    
    attr_reader :regexps
    
    def configure(conf)
      super
        
      @regexps = {}

      (1..REGEXP_MAX_NUM).each do |i|
        next unless conf["regexp#{i}"]
        key, regexp = conf["regexp#{i}"].split(/ /,2)
        event_id = conf["event_id#{i}"]
        event_desc = conf["event_desc#{i}"] ? conf["event_desc#{i}"] : nil
        raise ConfigError, "regexp#{i} does not contain 2 parameters" unless regexp
        raise ConfigError, "regexp#{i} does not have corresponding event ID" unless event_id
        event = SCOM::EventHolder.new(Regexp.compile(regexp), event_id, event_desc)
        unless @regexps[key]
          @regexps[key] = []
        end
        @regexps[key].push(event)
      end
    end
    
    def start
      super
    end
    
    def shutdown
      super
    end
    
    def filter(tag, time, record)
      result = record
      begin
        catch(:break_loop) do
          @regexps.each do |key, events|
            events.each do |event|
              if event.regexp.match(record[key].to_s)
                result = SCOM::Common.get_scom_record(time, event.event_id, event.event_desc)
                $log.debug "Event found for ID #{event.event_id}"
                throw :break_loop
              end
            end
          end
        end
      rescue => e
      end
      result
    end
    
  end 
end

