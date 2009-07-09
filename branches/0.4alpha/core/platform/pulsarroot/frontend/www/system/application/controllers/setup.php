<?php

class Setup extends Controller
{
	
	var $header_data = array('title' => 'PulsarOS Setup');

	function index()
	{
		$this->load->view('setup/header', $this->header_data);
		$this->load->view('setup/index');
	}
	
	function main($step,$input = array())
	{
		$data = array();
		if ($_POST) 
		{
			switch ($step) 
			{
				case 'step1':
					$data = $this->_step1();
					$i=0;
					foreach($data as $disk):
						$data['disk'][$i] = preg_split("/[\s,]+/", $disk);
						$i++;
					endforeach;
					break;
				case 'step2':
					$data['installsys'] = $this->_step2($_POST['disk']);
					break;
				case 'step3':
					$data['nwcard'] = $this->_step3();
					$i=0;
					foreach($data as $nwcard):
						$data['nwcard'][$i] = $nwcard;
						$i++;
					endforeach;
					break;
				case 'step4a':
				case 'step4b':
					$data['nwcard'] = $input['nwcard'];
					break;
				case 'step5':
					$data['configsys'] = $this->_step5($input);
					break;
			}
			$this->load->view('setup/header', $this->header_data);
			$this->load->view("setup/$step", $data);
		}
		else
		{
			$this->index();
		}
	}
	
	function form()
	{	
		$input = $_POST;
		$step = $input['step'];
		$nextstep = $input['next_step'];
		if ( isset($input['nwcard']) && $input['next_step'] == "step4")
		{
			$nextstep = $input['nwconf'];
		}	
		switch ($step) {
			case 'step1':
				$this->form_validation->set_rules('disk', 'Disk', 'required');
				break;
			case 'step3':
				$this->form_validation->set_rules('nwcard', 'Network card', 'required');
				break;
			case 'step4a':
				$this->form_validation->set_rules('hostname', 'Hostname', 'required');
				break;
			case 'step4b':
				break;
		}
		if ($this->form_validation->run() == FALSE)
		{
			$this->main($step, $input);
		}
		else
		{
			$this->main($nextstep, $input);
		}
	}
	
	function _step1()
	{
		exec('/pulsarroot/bin/setup/setup.sh get_disks', $output);
		return $output; 
	}
	
	function _step2($disk)
	{
		exec("/pulsarroot/bin/setup/setup.sh install_os $disk", $output);
		return $output;
	}
	
	function _step3()
	{
		exec("/pulsarroot/bin/setup/setup.sh get_net", $output);
		return $output;
	}
	
	function _step5($configos)
	{	
		if ( $configos['dhcp'] == "n" )
		{
			exec("/pulsarroot/bin/setup/setup.sh configure_os $configos[nwcard] $configos[dhcp] $configos[hostname] $configos[ipaddr] $configos[netmask] $configos[gateway] $configos[nameserver]", $output);
		}
		else
		{
			exec("/pulsarroot/bin/setup/setup.sh configure_os $configos[nwcard] $configos[dhcp] $configos[hostname]", $output);
		}
		return $output;
	}
}
?>