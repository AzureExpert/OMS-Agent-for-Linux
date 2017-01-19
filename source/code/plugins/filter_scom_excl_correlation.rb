module Fluent
  class SCOMExclusiveCorrelationFilter < Filter
    
    Fluent::Plugin.register_filter('scom_exclusive_correlation', self)

    config_param :regexp1, :string, :default => nil
    config_param :regexp2, :string, :default => nil
    config_param :time_interval, :integer, :default => 0
    config_param :event_id, :string, :default => nil
    config_param :event_desc, :string, :default => nil
        
    attr_reader :expression1
    attr_reader :key1
    attr_reader :expression2
    attr_reader :key2
    attr_reader :time_interval
        
    def initialize()
      super
      require_relative 'scom_common'
      @exp1_found = false
      @timer = nil
      @lock = Mutex.new
    end
        
    def configure(conf)
      super
            
      raise ConfigError, "Configuration does not contain 2 expressions" unless @regexp1 and @regexp2
      raise ConfigError, "Configuration does not have corresponding event ID" unless @event_id
      raise ConfigError, "Configuration does not have a time interval" unless @time_interval
      @key1, exp1 = @regexp1.split(/ /,2)
      raise ConfigError, "regexp1 does not contain 2 parameters" unless exp1
      @expression1 = Regexp.compile(exp1)
      @key2, exp2 = @regexp2.split(/ /,2)
      raise ConfigError, "regexp2 does not contain 2 parameters" unless exp2
      @expression2 = Regexp.compile(exp2)
    end
        
    def flip_state()
      @lock.synchronize {
        @exp1_found = !@exp1_found
      }
    end
        
    def filter(tag, time, record)
      if !@exp1_found and @expression1.match(record[key1].to_s)
        flip_state()
        $log.debug "Match found for regex #{@regexp1} ID #{@event_id}. Timer Started."
        @timer = Thread.new { sleep @time_interval; timer_expired() }
      end
      if @exp1_found and @expression2.match(record[key2].to_s)
        flip_state()
        @timer.terminate()
        @timer = nil
      end
      record
    end
        
    def timer_expired()
      flip_state()
      @timer = nil
      time = Engine.now
      result = SCOM::Common.get_scom_record(time, @event_id, @event_desc)
      $log.debug "Event found for ID #{@event_id}"
      router.emit("scom.event", time, result)
    end
        
  end
end



