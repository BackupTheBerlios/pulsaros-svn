<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Core {

	function osVersion() 
	{
		$output = exec('uname -s');
		if ($output == "Linux") 
		{
			return "linux";
		}
	}
	
	function pulsarVersion()
	{
		return "PulsarOS 0.5alpha";
	}
	
	function apiError() 
	{
		print "API Error! Please send the problem to a PulsarOS developer!";
	}
	
	function getSysinfo()
	{
		$cpuinfo = exec('cat /proc/cpuinfo |grep "model name"| awk \'{ print $4" "$5" " $6" "$7" "$8" "$9 }\'');
		$kernelversion = exec('uname -r');
		$memorysize = exec('cat /proc/meminfo |grep "MemTotal"|awk \'{ print $2 }\'');
		$output = "<div>
				<p><span>Processor: $cpuinfo</span>
				<span>Kernel Version: $kernelversion</span>
				<span>Memory: $memorysize Kbyte</span></p>
			   </div>"
			   ;
		return $output;
	}

	function getUptime()
	{
		$uptime = exec('uptime|awk \'{print $2" "$3" "$4" "$5" "$6" "$7" "$8" "$9}\'');
		$output = "<p>$uptime</p>";
		return $output;
	}
}

?>
