<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

class Network {

	function get_nwcards($osversion) 
	{
		// html format of the network cards
		exec("/pulsarroot/frontend/bin/$osversion/setup/setup.sh get_net", $output['nwcard']);
		$i=0;
		foreach($output['nwcard'] as $nwcard):
			if ($i == 0) {
				$html[$i]="<input class=validate['required'] type='radio' name='nwcard' value=$nwcard />Interface: $nwcard<br />";
			}
			else {
				$html[$i]="<input type='radio' name='nwcard' value=$nwcard />Interface: $nwcard<br />";
			}
			$i++;
		endforeach;
		return $html;
	}
}

?>
