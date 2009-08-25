<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Core {

	function osversion() 
	{
		$output = exec('uname -s');
		if ($output == "SunOS") 
		{
			return "opensolaris";
		}
	}
}

?>
