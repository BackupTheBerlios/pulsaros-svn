<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Disk {

	function get_disks($osversion) 
	{
		// html format of the disks
		exec("/pulsarroot/frontend/bin/$osversion/setup/setup.sh get_disks", $output['disks']);
		$i=0;
		foreach($output['disks'] as $disk):
			$data['disk'] = preg_split("/[\s,]+/", $disk);
			if ($i == 0) {
				$html[$i]="<input class=validate['required'] type='radio' name='disk' value='".$data['disk'][0]."' />Disk: ".$data['disk'][0]." Size: ".$data['disk'][1]."<br />";
			}
			else {
				$html[$i]="<input type='radio' name='disk' value='".$data['disk'][0]."' />Disk: ".$data['disk'][0]." Size: ".$data['disk'][1]."<br />";
			}
			$i++;
		endforeach;
		return $html;
	}
}

?>
