<?php if (! defined('BASEPATH')) exit('No direct script access allowed');

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
