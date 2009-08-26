<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Disk {

	function getDisks($osversion) 
	{
		// html format of the disks
		exec("/pulsarroot/frontend/bin/$osversion/setup/setup.sh get_disks", $output['disks']);
		if (empty($output['disks'])) {
			$html = "<p>No disks found, please contact the support!</p>";
		}
		else {
			$i=0;
			foreach($output['disks'] as $disk):
				$data['disk'] = preg_split("/[\s,]+/", $disk);
				if ($i == 0) {
					$html[$i]="<div class='disk'>
							   		<input class=validate['required'] type='radio' name='disk' value='".$data['disk'][0]."' />
							   		<img src='/images/disk.png' />
							   		<div class='desc'>
							   			<p>Name: ".$data['disk'][0]."</p>
							   			<p>Capacity: ".$data['disk'][1]."</p>
							   		</div>
							   </div>";
				}
				else {
					$html[$i]="<div class='disk'>
							   		<input type='radio' name='disk' value='".$data['disk'][0]."' />
							   		<img src='/images/disk.png' />
							   		<div class='desc'>
							   			<p>Name: ".$data['disk'][0]."</p>
							   			<p>Capacity: ".$data['disk'][1]."</p>
							   		</div>
							   </div>";
				}
				$i++;
			endforeach;
		}
		return $html;
	}
}
?>
