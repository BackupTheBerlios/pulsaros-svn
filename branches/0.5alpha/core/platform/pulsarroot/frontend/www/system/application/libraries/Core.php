<?php if(! defined('BASEPATH')) exit('No direct script access allowed');

class Core {

	function osversion {
	 	exec ('uname -s', $output)
		if ($output == "SunOS") {
			return "opensolaris"
		fi
	}
}

?>
