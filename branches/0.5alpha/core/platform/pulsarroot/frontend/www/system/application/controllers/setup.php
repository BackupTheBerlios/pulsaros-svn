<?php

class Setup extends Controller
{

	function __construct()
	{
		parent::Controller();
		// Initialize needed libraries
		$this->load->library('core');
		$this->load->library('disk');
		$this->load->library('network');

		// Global variables for this class
		$this->header_data = array('title' => 'PulsarOS Setup');
		$this->osversion = $this->core->osversion();
	}
	
	function index()
	{
		$html = $this->_step1();
		$this->load->view('setup/header', $this->header_data);
		$this->load->view("setup/index", $html);
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
		$html['disks'] = $this->disk->get_disks($this->osversion);
		$html['nwcards'] = $this->network->get_nwcards($this->osversion);
		return $html;
	}
	
	function _step2($data)
	{
		if (isset($data['dhcp'])) {
			exec("/pulsarroot/frontend/bin/$this->osversion/setup/setup.sh install_os $data[disk] $data[nwcard] y $data[hostname]", $output);
			return $output;
		}
		else {
		return	exec("/pulsarroot/frontend/bin/$this->osversion/setup/setup.sh install_os $data[disk] $data[nwcard] n $data[hostname] $data[ipaddr] $data[netmask] $data[gateway] $data[nameserver]");
		}
	}
}
?>