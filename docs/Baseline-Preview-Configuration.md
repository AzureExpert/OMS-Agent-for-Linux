# Configuration for Security Baseline data collection and assessment (Preview)

1. Download the OMS Agent for Linux, version 1.2.0-148 or above:  
	* [OMS Agent for Linux GA v1.2.0-148](https://github.com/Microsoft/OMS-Agent-for-Linux/releases/tag/OMSAgent-201610-v1.2.0-148)    

2. Install and configure the agent as described here:  
  * [Documentation for OMS Agent for Linux](https://github.com/Microsoft/OMS-Agent-for-Linux)  

3. Place the following files on the OMS Agent machine:  
	* [security_baseline.conf](https://github.com/Microsoft/OMS-Agent-for-Linux/blob/master/installer/conf/omsagent.d/security_baseline.conf)  
	_Fluentd configuration file to enable collection and assessment Security Baseline_  
	Destination path on Agent machine: ```/etc/opt/microsoft/omsagent/conf/omsagent.d/```  
    
	* [oms_audits.xml](https://github.com/Microsoft/OMS-Agent-for-Linux/blob/master/installer/conf/omsagent.d/oms_audits.xml)  
	_Security Baseline Assessment Rules collection_  
	Destination path on Agent machine: ```/etc/opt/microsoft/omsagent/conf/omsagent.d/```  

	* [filter_security_baseline.rb](https://github.com/Microsoft/OMS-Agent-for-Linux/blob/master/source/code/plugins/filter_security_baseline.rb)  
	_Fluentd Security Baseline filter plugin_  
	Destination path on Agent machine: ```/opt/microsoft/omsagent/plugin/```  

	* [security_baseline_lib.rb](https://github.com/Microsoft/OMS-Agent-for-Linux/blob/master/source/code/plugins/security_baseline_lib.rb)  
	_Main Security Baseline implementation library_  
	Destination path on Agent machine: ```/opt/microsoft/omsagent/plugin/``` 

	* [omsbaseline_x64](https://github.com/Microsoft/OMS-Agent-for-Linux/blob/master/source/code/plugins/omsbaseline_x64)
    _or_
    * [omsbaseline_x86](https://github.com/Microsoft/OMS-Agent-for-Linux/blob/master/source/code/plugins/omsbaseline_x86)  
	_Security Baseline tool for collection and assessment data_  
    _Only one file should be used according to server architecture (32/64 bits)_  
    _
    Destination file name: ```omsbaseline```     
	Destination path on Agent machine: ```/opt/microsoft/omsagent/plugin/```
    Destination file permissions: ```755 ?????????? ```     
    
4. Restart the OMS agent:  
```sudo service omsagent restart``` or ```systemctl restart omsagent```

5. Confirm that there are no errors in the OMS Agent log:  
```tail /var/opt/microsoft/omsagent/log/omsagent.log```

6. The Security Baseline Summary assessment results will appear in OMS under the **SecurityBaseline** or ***SecurityBaselineSummary* types.  
Log search queries: ```Type=SecurityBaseline``` or ```Type=SecurityBaselineSummary```
