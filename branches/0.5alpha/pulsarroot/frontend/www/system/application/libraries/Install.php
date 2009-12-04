<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

/**
 * 

 * 
 * Description
 * 
 * @license		GNU General Public License
 * @author		Thomas Brandstetter
 * @link		http://www.digitalplayground.at
 * @email		thomas.brandstetter@gmail.com
 * 
 * @file		Install.php
 * @version		1.0
 * @date		12/02/2009
 * 
 * Copyright (c) 2009
 */
 
class Install {

	function installOs($data) 
	{
		// install pulsarOS to disk
		if (isset($data['dhcp'])) {
			return exec("/pulsarroot/frontend/bin/setup/setup.sh install_os $data[disk] $data[nwcard] $data[dhcp] $data[hostname]");
		}
		else {
			return	exec("/pulsarroot/frontend/bin/setup/setup.sh install_os $data[disk] $data[nwcard] n $data[hostname] $data[ipaddr] $data[netmask] $data[gateway] $data[nameserver]");
		}
	}
}

?>
