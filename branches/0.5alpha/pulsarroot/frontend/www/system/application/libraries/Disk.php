<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Disk {

	function getDisks($type) 
	{
		// shows all disks available for installation
		if ( $type == "setup" ) {
			exec("/pulsarroot/frontend/bin/setup/setup.sh get_disks", $html['disks']);
			if (empty($html['disks'])) {
				$output = "<p>No disks found, please contact the PulsarOS team!</p>";
			}
			else {
				$i=0;
				foreach($html['disks'] as $disk):
					$data['disk'] = preg_split("/[\s,]+/", $disk);
					if ($i !== 0) {
						if ($i == 1) {
							$output[$i]="<div class='disk'>
							   				<input class=validate['required'] type='radio' name='disk' value='".$data['disk'][0]."' />
							   				<img src='/images/disk.png' />
							   				<div class='desc'>
							   					<p>Name: ".$data['disk'][0]."</p>
							   					<p>Capacity: ".$data['disk'][1]."</p>
							   				</div>
							   		   </div>";
						}
						else {
							$output[$i]="<div class='disk'>
											<input type='radio' name='disk' value='".$data['disk'][0]."' />
							   				<img src='/images/disk.png' />
							   				<div class='desc'>
							   					<p>Name: ".$data['disk'][0]."</p>
							   					<p>Capacity: ".$data['disk'][1]."</p>
							   				</div>
							   	   	   </div>";
						}
					}
					$i++;
				endforeach;
			}
		}
		else {
			$rootdisk = substr(exec('mount|grep pulsarroot|awk \'{ print $1 }\''), 0, -1);
			exec('fdisk -l|grep Disk|grep -v partition|grep -v '. $rootdisk .'|awk \'{print $2}\'|awk -F: \'{print $1}\'', $output['disks']);
			$output['list'] = "";
			$output['count'] = 0;
			foreach($output['disks'] as $disk):
				$output['list'] .= "$disk ";
				$output['count']++;
			endforeach;
		}	 
		return $output;
	}
	
	function chooseStorage()
	{
		// Shows a list of available btrfs pool options depending on the number of available disks (raid0, raid10, mirroring)
		$disks = $this->getDisks('storage');
		$disklist = $disks['list'];
		$diskcount = $disks['count'];
		$striped = "<input type='hidden' name='disks' value='$disklist' />
					<div class='cell'>
							<input class=validate['required'] type='radio' name='method' value='striped' />
				   			<img src='/images/bigone.png' alt='Big One' />
					</div>";
		$mirrored = "<div class='cell'>
							<input type='radio' name='method' value='mirrored' />
				   			<img src='/images/safetyfirst.png' alt='Safety first' />
				   	 </div>";
		$raid10 = "<div class='cell'>
				   			<input type='radio' name='method' value='raid10' />
				   			<img src='/images/unbreakable.png' alt='Unbreakable' />
				   </div>";	
		if ($diskcount == 1) {
			$output = "$striped";
		}		   
		elseif ($diskcount < 3) {
			$output = " $striped
			   	    $mirrored";
		}
		elseif ($diskcount >= 3) {
			$output = "$striped
				   $raid10";
		}
		return $output;
	}
	
	function getStorage($type='pool')
	{
		// Shows all disks of the btrfs pool
		$storagename = exec('btrfs-show|grep Label|awk \'{ print $2 }\'');
		exec('btrfs-show|grep devid| awk \'{ print $4" "$8}\'|awk -F/ \'{ print $1 $3}\'', $storage['disks']);
		if ( $type == "pool" ) {
			$output = "<p><span>Storagepool: $storagename</span></p>
				   	   <div id='container'>";
			foreach($storage['disks'] as $disk):
				$data['disk'] = preg_split("/[\s,]+/", $disk);
				$output .="<div class='storage'>
								<div class='img'>
									<img src='/images/storage.png' />
									<br />
									<img class='stat' src='/images/accept.png' />
								</div>
								<div class='desc'>
									<p>Name: ".$data['disk'][1]."</p>
							   		<p>Capacity: ".$data['disk'][0]."</p>
								</div>
					   	   </div>";
			endforeach;
			$output .="</div><div class='clear'></div>";
		}
		else {
			exec('btrfs-show|grep devid| awk \'{ print $4" "$8}\'|awk \'{ print $2}\'', $output['disks']);
		}
		return $output;
	}
	
	function setStorage($data)
	{
		// Creates a btrfs pool depending on the number of available disks
		switch($data['method'])
		{
			case "striped":
				exec ('mkfs.btrfs -L data -m raid0 -d raid0 '. $data['disks'] .'', $output);
				break;
			case "mirrored":
				exec ('mkfs.btrfs -L data -m raid1 -d raid1 '. $data['disks'] .'', $output);
				break;
			case "raid10":
				exec ('mkfs.btrfs -L data -m raid10 -d raid10 '. $data['disks'] .'', $output);
				break;
		}
	}
	
	function deleteStorage($data)
	{
		if ( $data['storage'] == "y" ) {
			// Deletes the created btrfs pool
			$disklist = $this->getStorage('list');
			foreach($disklist['disks'] as $disk):
				exec ('dd if=/dev/zero of='. $disk .' bs=8192 count=10');
			endforeach;
		}
		
	}
		
	function getVolumes()
	{
		// Shows a list of all configured btrfs subvolumes
		$devname = exec('btrfs-show |grep devid|tail -1|awk \'{print $8}\'');
		$volumename = exec('btrfs-debug-tree '. $devname .'|grep -A1 ROOT_REF|grep name|awk \'{ print $9 }\'', $volumes['names']);
		$output = "";
		foreach($volumes['names'] as $disk):
			$output .="<div class='volumes'>
							<div class='name'>$disk</div>
							<div class='stat'></div>
							<div class='desc'></div>
						</div>";
		endforeach;
		return $output;
	}
	
	function setVolumes($data)
	{
		
		return $output;
	}
}
?>