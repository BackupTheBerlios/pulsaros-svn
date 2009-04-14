  <body>	
	<h1>Step 1</h1>
	<p>Choose the disk to install the os:</p>
	<ul>
	<?php foreach($getdisk as $disk):?>
	<li><?php echo $disk;?></li>
	<?php endforeach;?>
	<p>All data on disk will be destroyed - click <a href="http://<?php echo "$ip:$port"; ?>/index.php?setup/main/step2/disk">here</a></p> 
  <body>
</html>
