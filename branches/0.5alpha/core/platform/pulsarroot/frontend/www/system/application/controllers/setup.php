<?php

class Setup extends Controller
{
	
	var $header_data = array('title' => 'PulsarOS Setup');
	
	function index()
	{
		$data = $this->_step1();
		$i=0;
		foreach($data['disks'] as $disk):
			$data['disk'][$i] = preg_split("/[\s,]+/", $disk);
			$i++;
		endforeach;
		$i=0;
		foreach($data['nwcard'] as $nwcard):
			$data['nwcard'][$i] = $nwcard;
			$i++;
		endforeach;
		$this->load->view('setup/header', $this->header_data);
		$this->load->view("setup/index", $data);
	}
	
	function install()
	{
		if (!empty($_POST)) {
			print $this->_step2($_POST);
		}
		else {
			echo "Empty POST array";
		}
	}
		
	function _step1()
	{
		exec('/pulsarroot/bin/setup/setup.sh get_disks', $output['disks']);
		exec('/pulsarroot/bin/setup/setup.sh get_net', $output['nwcard']);
		return $output; 
	}
	
	function _step2($data)
	{
		if (isset($data['dhcp'])) {
			exec("/pulsarroot/bin/setup/setup.sh install_os $data[disk] $data[nwcard] y $data[hostname]", $output);
		}
		else {
			exec("/pulsarroot/bin/setup/setup.sh install_os $data[disk] $data[nwcard] n $data[hostname] $data[ipaddr] $data[netmask] $data[gateway] $data[nameserver]", $output);
		}
		return $output; 
	}
}
?>