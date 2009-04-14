  <body>	
	<h1>Step 3</h1>
	<p>PulsarOS configuration</p>
	<ul>
	<?php foreach($configsys as $step):?>
	<li><?php echo $step;?></li>
	<?php endforeach;?>
	<p>PulsarOS configured - after shutdown, remove your usb-stick or cd/dvd. To shutdown the system now, click <a href="http://<?php echo "$ip:$port"; ?>/index.php?setup/main/step3">here</a></p> 
  <body>
</html>
