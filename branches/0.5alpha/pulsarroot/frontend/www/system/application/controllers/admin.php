<?php

class Admin extends Controller
{

	function __construct()
	{
		parent::Controller();
		// Initialize needed libraries
		$this->load->library('core');
		$this->load->library('disk');

		// Global variables for this class
		$this->header_data = array('title' => 'PulsarOS Frontend');
	}
	
	function index()
	{
		$html['sysinfo'] = $this->core->getSysinfo();
		$html['version'] = $this->core->pulsarVersion();
		$html['uptime'] = $this->core->getUptime();
		$html['storage'] = $this->core->getStorage();
		$html['menu'] = $this->core->getMenu();
		$this->load->view('admin/header', $this->header_data);
		$this->load->view('admin/index', $html);
	}
	
	function settings()
	{
		$html['menu'] = $this->core->getMenu();
		$this->load->view('admin/header', $this->header_data);
		$this->load->view('admin/settings', $html);
	}
	
	function network()
	{
		$html['menu'] = $this->core->getMenu();
		$this->load->view('admin/header', $this->header_data);
		$this->load->view('admin/network', $html);
	}
	
	function backup()
	{
		$html['menu'] = $this->core->getMenu();
		$this->load->view('admin/header', $this->header_data);
		$this->load->view('admin/backup', $html);
	}
	
	function volumes()
	{
		if (!empty($_POST)) {
			$this->disk->setVolumes($_POST);
		}
		elseif ( $this->core->getStorage() == "<p>No storage configured yet!</p>" ) {
					$this->storage();
		}
		else {
			$html['volumes'] = $this->disk->getVolumes();
			$html['menu'] = $this->core->getMenu();
			$this->load->view('admin/header', $this->header_data);
			$this->load->view('admin/volumes', $html);
		}
	}
	
	function pool()
	{
		if (!empty($_POST)) {
			$this->disk->deleteStorage($_POST);
		}
		elseif ( $this->core->getStorage() == "<p>No storage configured yet!</p>" ) {
			$this->storage();
		}
		else {
			$html['storage'] = $this->disk->getStorage();
			$html['menu'] = $this->core->getMenu();
			$this->load->view('admin/header', $this->header_data);
			$this->load->view('admin/pool', $html);
		}
	}
	
	function storage()
	{
		if (!empty($_POST)) {
			$this->disk->setStorage($_POST);
		}
		else {
			$html['options'] = $this->disk->chooseStorage();
			$html['menu'] = $this->core->getMenu();
			$this->load->view('admin/header', $this->header_data);
			$this->load->view('admin/storage', $html);
		}
	}
}
?>
