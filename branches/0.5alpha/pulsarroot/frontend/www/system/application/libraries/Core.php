<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Core {
	
	function pulsarVersion()
	{
		return "PulsarOS 0.5alpha";
	}
	
	function apiError() 
	{
		print "API Error! Please send the problem to a PulsarOS developer!";
	}
	
	function getMenu()
	{
		$output = "<p class='bold'>Menu</p>
  				   <p><a href='index.php?admin/index' title='Overview'>Overview</a></p>
  				   <p><a href='index.php?admin/settings' title='Settings'>Settings</a></p>
  				   <p><a href='index.php?admin/network' title='Network'>Network</a></p>
  				   <p><a href='index.php?admin/backup' title='Backup/Restore'>Backup/Restore</a></p>
  				   <br />
  				   <p class='bold'>Storage</p>
  				   <p><a href='index.php?admin/pool' title='Pool'>Pool</a></p>
  				   <p><a href='index.php?admin/volumes' title='Volumes'>Volumes</a></p>
  				   <br />
  				   <p class='bold'>Plugins</p>
  				   <p>Install</p>
  				   <p>Configure</p>";
  		return $output;
	}
	
	function getSysinfo()
	{
		$cpuinfo = exec('cat /proc/cpuinfo |grep "model name"| awk \'{ print $4" "$5" " $6" "$7" "$8" "$9 }\'');
		$kernelversion = exec('uname -r');
		$memory = exec('cat /proc/meminfo |grep "MemTotal"|awk \'{ print $2 }\'');
		$memorysize = floor($memory / 1000);
		$output = "<div>
				<p><span>Processor: $cpuinfo</span>
				<span>Kernel Version: $kernelversion</span>
				<span>Memory: $memorysize Mbyte</span></p>
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

	function getStorage()
	{
		$storageid = exec('btrfs-show |grep "Label"|awk \'{ print $1" "$2 }\'');
		if (!empty($storageid)) {
			$output = "<p>$storageid</p>";	
                }
                else {
			$output = "<p>No storage configured yet!</p>";
                }
		return $output;
	}
}

?>
