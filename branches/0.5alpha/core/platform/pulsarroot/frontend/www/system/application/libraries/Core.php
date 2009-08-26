<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Core {

	function osVersion() 
	{
		$output = exec('uname -s');
		if ($output == "SunOS") 
		{
			return "opensolaris";
		}
	}
	
	function apiError() 
	{
		print "API Error! Please send the problem to a PulsarOS developer!";
	}
}

?>
