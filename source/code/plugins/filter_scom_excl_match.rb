module Fluent
  class SCOMExclusiveMatchFilter < Filter
    
    Fluent::Plugin.register_filter('scom_exclusive_match', self)
        
    def initialize
      super
      require_relative 'scom_common'
    end
        
    config_param :regexp1, :string, :default => nil
    config_param :regexp2, :string, :default => nil
    config_param :event_id, :string, :default => nil
    config_param :event_desc, :string, :default => nil
        
    attr_reader :expression1
    attr_reader :key1
    attr_reader :expression2
    attr_reader :key2
        
    def configure(conf)
      super
      raise ConfigError, "Configuration does not contain 2 expressions" unless (@regexp1 and @regexp2)
      raise ConfigError, "Configuration does not have corresponding event ID" unless @event_id
      @key1, exp1 = @regexp1.split(/ /,2)
      raise ConfigError, "regexp1 does not contain 2 parameters" unless exp1
      @expression1 = Regexp.compile(exp1)
      @key2, exp2 = @regexp2.split(/ /,2)
      raise ConfigError, "regexp2 does not contain 2 parameters" unless exp2
      @expression2 = Regexp.compile(exp2)
    end
        
    def filter(tag, time, record)
      result = record
      if @expression1.match(record[key1].to_s) and !(@expression2.match(record[key2].to_s))
        result = SCOM::Common.get_scom_record(time, @event_id, @event_desc)
        $log.debug "Event found for ID #{@event_id}"
      end
      result
    end
        
  end
end

