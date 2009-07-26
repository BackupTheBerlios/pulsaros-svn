<?php

class Admin extends Controller
{
	
	var $header_data = array('title' => 'PulsarOS Frontend');

	function index()
	{
		$this->load->view('admin/header', $this->header_data);
		$this->load->view('admin/index');
	}
}
?>
