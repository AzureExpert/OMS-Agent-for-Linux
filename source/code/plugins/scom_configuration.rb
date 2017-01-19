module SCOM

  class Configuration
    require 'openssl'
    require 'uri'
        
    require_relative 'oms_configuration'
    require_relative 'omslog'
        
    @@configuration_loaded = false
    @@scom_conf_path = '/etc/opt/microsoft/omsagent/scom/conf/omsadmin.conf'
    @@cert_path = '/etc/opt/microsoft/scx/ssl/scx.pem'
    @@key_path =  '/etc/opt/omi/ssl/omikey.pem'     
  
    @@cert = nil
    @@key = nil
        
    @@scom_endpoint = nil
    @@scom_event_endpoint = nil
    @@scom_perf_endpoint = nil
    
    @@monitoring_id = nil    
      
    def self.load_scom_configuration
      return true if @@configuration_loaded
      return false if !OMS::Configuration.test_onboard_file(@@scom_conf_path) or !OMS::Configuration.test_onboard_file(@@cert_path) or !OMS::Configuration.test_onboard_file(@@key_path)
            
      scom_endpoint_lines = IO.readlines(@@scom_conf_path).select{ |line| line.start_with?("SCOM_ENDPOINT")}
      if scom_endpoint_lines.size == 0
        OMS::Log.error_once("Could not find SCOM_ENDPOINT in #{conf_path}")
        return false
      elsif scom_endpoint_lines.size == 0
        OMS::Log.warn_once("Found more than one SCOM_ENDPOINT setting in #{conf_path}, will use the first one.")
      end 
            
      begin
        scom_endpoint_url = scom_endpoint_lines[0].split("=")[1].strip
        @@scom_endpoint = URI.parse( scom_endpoint_url )
        @@scom_event_endpoint = @@scom_endpoint.clone
        @@scom_event_endpoint.path = '/RESTWCFServiceLibrary/events'
        @@scom_perf_endpoint = @@scom_endpoint.clone
        @@scom_perf_endpoint.path = '/RESTWCFServiceLibrary/perf'
      rescue => e
        OMS::Log.error_once("Error parsing endpoint url. #{e}")
        return false
      end
  
      monitoring_id_lines = IO.readlines(@@scom_conf_path).select{ |line| line.start_with?("MONITORING_ID")}
      if monitoring_id_lines.size == 0
        OMS::Log.error_once("Could not find MONITORING_ID in #{@@scom_conf_path}")
        return false
      elsif monitoring_id_lines.size == 0
        OMS::Log.warn_once("Found more than one MONITORING_ID setting in #{@@scom_conf_path}, will use the first one.")
      end
      
      begin
        @@monitoring_id = monitoring_id_lines[0].split("=")[1].strip
      rescue => e
        OMS::Log.error_once("Error parsing monitoring id. #{e}")
        return false
      end
             
      begin
        raw = File.read @@cert_path
        @@cert = OpenSSL::X509::Certificate.new raw
        raw = File.read @@key_path
        @@key = OpenSSL::PKey::RSA.new raw
      rescue => e
        OMS::Log.error_once("Failed to read certificate or key from #{@@cert_path} #{@@key_path}")
        return false
      end
              
      @@configuration_loaded = true
      return true

    end

    def self.scom_event_endpoint
      @@scom_event_endpoint
    end

    def self.cert
      @@cert
    end

    def self.key
      @@key
    end

    def self.monitoring_id
      @@monitoring_id
    end

    def self.scom_perf_endpoint
      @@scom_perf_endpoint
    end

  end
end

