  <body>	
	<h1>Step 4</h1>
	<p>PulsarOS configuration</p>
	<?php echo validation_errors(); ?>
	<form method="post" action="index.php?setup/form">
	Hostname:<input type="text" name="hostname" value=""><br />
	IP Address:<input type="text" name="ipaddr" value=""><br />
	Netmask:<input type="text" name="netmask" value=""><br />
	Gateway:<input type="text" name="gateway" value=""><br />
	Nameserver:<input type="text" name="nameserver" value=""><br />
	<input type="submit" value="next">
	<input type="hidden" name="next_step" value="step5">
	<input type="hidden" name="step" value="step4b">
	<input type="hidden" name="nwcard" value=<?php echo $nwcard ?>>
	<input type="hidden" name="dhcp" value="n">
	</form> 
  <body>
</html>
