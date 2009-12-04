<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

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
 * @file		Network.php
 * @version		1.0
 * @date		12/02/2009
 * 
 * Copyright (c) 2009
 */
 
class Network {

	function getNwcards() 
	{
		// html format of the network cards
		exec("/pulsarroot/frontend/bin/setup/setup.sh get_net", $output['nwcard']);
		if (empty($output['nwcard'])) {
			$html = "<p>No network cards found, please contact the support!</p>";
		}
		else {
			$i=0;
			foreach($output['nwcard'] as $nwcard):
				if ($i == 0) {
					$html[$i]="<p><input class=validate['required'] type='radio' name='nwcard' value=$nwcard />Interface: $nwcard</p>";
				}
				else {
					$html[$i]="<p><input type='radio' name='nwcard' value=$nwcard />Interface: $nwcard</p><br />";
				}
				$i++;
			endforeach;
		}
		return $html;
	}
}

?>
