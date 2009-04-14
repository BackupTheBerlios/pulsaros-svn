<?php

class Setup extends Controller {
	
	function main($step,$disk="")
	{
		$data = array();
		$header_data = array('title' => 'PulsarOS Setup',
               			     'ip' => '10.0.0.253',
               			     'port' => '8080'
          			    );
		switch ($step) {
			case 'step1':
				$data['getdisk'] = $this->_step1();
				break;
			case 'step2':
				$data['installsys'] = $this->_step2($disk);
				break;
			case 'step3':
				$data['configsys'] = $this->_step3($disk);
				break;
		}
		$this->load->view('setup/header', $header_data);
		$this->load->view("setup/$step", $data);
	}
	
	function _step1()
	{
		exec('/installer/0.4alpha/core/platform/pulsarroot/bin/setup/setup.sh get_disks', $output);
		return $output; 
	}
	
	function _step2($disk)
	{
		exec("/installer/0.4alpha/core/platform/pulsarroot/bin/setup/setup.sh format_disk $disk", $format);
		$data['formatdisk'] = $format[0];
		exec("/installer/0.4alpha/core/platform/pulsarroot/bin/setup/setup.sh install_os $disk", $install);
		$data['installos'] = $install[0];
		exec("/installer/0.4alpha/core/platform/pulsarroot/bin/setup/setup.sh os_bootable $disk", $bootable);
		$data['bootableos'] = $bootable[0];
		return $data;
	}
	
	function _step3($disk)
	{
		exec("/installer/0.4alpha/core/platform/pulsarroot/bin/setup/setup.sh configure_os $disk", $configure);
		$data['configureos'] = $configure[0];
		return $data;
	}
}
?>
