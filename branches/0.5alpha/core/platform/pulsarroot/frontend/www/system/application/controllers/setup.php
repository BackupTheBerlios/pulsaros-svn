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
		$this->load->library('install');

		// Global variables for this class
		$this->header_data = array('title' => 'PulsarOS Setup');
		$this->osversion = $this->core->osVersion();
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
			$this->core->apiError();
		}
	}
		
	function _step1()
	{
		$html['disks'] = $this->disk->getDisks($this->osversion);
		$html['nwcards'] = $this->network->getNwcards($this->osversion);
		return $html;
	}
	
	function _step2($data)
	{
		$this->install->installOs($this->osversion, $data);
	}
}
?>