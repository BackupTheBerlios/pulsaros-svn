  <body>	
	<h1>Step 3</h1>
	<p>PulsarOS configuration</p>
	<?php echo validation_errors(); ?>
	<form method="post" action="index.php?setup/form">
	<?php foreach($nwcard[0] as $nwname):?>
	<input type="radio" name="nwcard" value=<?php echo $nwname;?>> <?php echo "Interface: $nwname";?><br />
	<?php endforeach;?>
	<p>Choose your network card for configuration</p><br />
	<p>Configure interface using:</p>
	<select name="nwconf">
		<option value="step4a">DHCP</option>
		<option value="step4b">STATIC</option>
	</select>
	<input type="submit" value="submit">
	<input type="hidden" name="next_step" value="step4">
	<input type="hidden" name="step" value="step3">
	</form> 
  <body>
</html>
