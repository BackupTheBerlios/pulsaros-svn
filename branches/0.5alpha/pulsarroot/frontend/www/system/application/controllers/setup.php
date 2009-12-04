<?php

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
 * @file		setup.php
 * @version		1.0
 * @date		12/02/2009
 * 
 * Copyright (c) 2009
 */
 
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
		$html['disks'] = $this->disk->getDisks("setup");
		$html['nwcards'] = $this->network->getNwcards();
		return $html;
	}
	
	function _step2($data)
	{
		$this->install->installOs($data);
	}
}
?>