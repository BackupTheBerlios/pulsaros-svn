  <body>	
	<h1>Step 4</h1>
	<p>PulsarOS configuration</p>
	<?php echo validation_errors(); ?>
	<form method="post" action="index.php?setup/form">
	Hostname:<input type="text" name="hostname" value=""><br />
	<input type="submit" value="submit">
	<input type="hidden" name="next_step" value="step5">
	<input type="hidden" name="step" value="step4a">
	<input type="hidden" name="nwcard" value=<?php echo $nwcard ?>>
	<input type="hidden" name="dhcp" value="y">
	</form> 
  <body>
</html>
