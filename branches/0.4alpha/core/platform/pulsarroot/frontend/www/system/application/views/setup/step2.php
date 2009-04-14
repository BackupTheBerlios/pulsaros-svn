  <body>	
	<h1>Step 2</h1>
	<p>PulsarOS installation status</p>
	<ul>
	<?php foreach($installsys as $step):?>
	<li><?php echo $step;?></li>
	<?php endforeach;?>
	<p>PulsarOS installed - for configuration click <a href="http://<?php echo "$ip:$port"; ?>/index.php?setup/main/step3/disk">here</a></p> 
  <body>
</html>
