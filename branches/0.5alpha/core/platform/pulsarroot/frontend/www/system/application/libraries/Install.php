<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Install {

	function installOs($osversion, $data) 
	{
		// install pulsarOS to disk
		if (isset($data['dhcp'])) {
			return exec("/pulsarroot/frontend/bin/$osversion/setup/setup.sh install_os $data[disk] $data[nwcard] y $data[hostname]");
		}
		else {
			return	exec("/pulsarroot/frontend/bin/$osversion/setup/setup.sh install_os $data[disk] $data[nwcard] $data[dhcp] $data[hostname] $data[ipaddr] $data[netmask] $data[gateway] $data[nameserver]");
		}
	}
}

?>
