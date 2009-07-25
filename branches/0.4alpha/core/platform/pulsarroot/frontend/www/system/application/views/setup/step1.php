  <body>	
	<h1>Step 1</h1>
	<p>Choose the disk to install the os:</p>
	<?php echo validation_errors(); ?>
	<form method="post" action="index.php?setup/form">
	<?php foreach($disk as $diskname):?>
	<input type="radio" name="disk" value=<?php echo $diskname[0];?>> <?php echo "Disk: $diskname[0] Size: $diskname[1]";?><br />
	<?php endforeach;?>
	<p>All data on disk will be destroyed!</p>
	<input type="submit" value="next">
	<input type="hidden" name="next_step" value="step2">
	<input type="hidden" name="step" value="step1">
	</form>
  <body>
</html>
