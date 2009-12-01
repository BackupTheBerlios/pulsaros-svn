<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

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
