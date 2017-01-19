module Fluent
  class SCOMRepeatedCorrelationFilter < Filter
    
    Fluent::Plugin.register_filter('scom_repeated_correlation', self)
        
    config_param :regexp1, :string, :default => nil
    config_param :num_occurences, :integer, :default => 0
    config_param :time_interval, :integer, :default => 0
    config_param :event_id, :string, :default => nil
    config_param :event_desc, :string, :default => nil
        
    attr_reader :expression
    attr_reader :key
    attr_reader :time_interval
    attr_reader :num_occurences
        
    def initialize()
      super
      require_relative 'scom_common'
      @exp1_found = false
      @timer = nil
      @lock = Mutex.new
      @counter = 0
    end
        
    def configure(conf)
      super
            
      raise ConfigError, "Configuration does not contain a expressions" unless @regexp1
      raise ConfigError, "Configuration does not have corresponding event ID" unless @event_id
      raise ConfigError, "Configuration does not have a time interval" unless (@time_interval > 0)
      raise ConfigError, "Configuration does not have number of occurences" unless (@num_occurences > 0)
      @key, exp = @regexp1.split(/ /,2)
      raise ConfigError, "regexp1 does not contain 2 parameters" unless exp
      @expression = Regexp.compile(exp)
    end
        
    def flip_state()
      @lock.synchronize {
        @exp1_found = !@exp1_found
      }
    end
        
    def reset_counter()
      @lock.synchronize {
        @counter = 0
      }
    end
        
    def filter(tag, time, record)
      result = record
            
      if !@exp1_found and @expression.match(record[key].to_s)
        flip_state()
        @counter += 1
        $log.debug "Match found for regex #{@regexp1} ID #{@event_id}. Timer Started."
        @timer = Thread.new { sleep @time_interval; timer_expired() }
      elsif @exp1_found and @expression.match(record[key].to_s) 
        @counter += 1
      end

      if @counter == @num_occurences
        flip_state()
        reset_counter()
        @timer.terminate()
        @timer = nil
        result = SCOM::Common.get_scom_record(time, @event_id, @event_desc)
        $log.debug "Event found for ID #{@event_id}"
      end
      result
    end
        
    def timer_expired()
      $log.debug "Timer expired waiting for event ID #{@event_id}"
      flip_state()
      reset_counter()
      @timer = nil
    end
        
  end
end



