  <body>	
	<h1>Step 2</h1>
	<p>PulsarOS installation status</p>
	<ul>
	<?php foreach($installsys as $step):?>
	<li><?php echo $step;?></li>
	<?php endforeach;?>
	<p>PulsarOS installed!</p>
	<form method="post" action="index.php?setup/main/step3">
		<input type="submit" value="submit">
		<input type="hidden" name="next_step" value="step3">
		<input type="hidden" name="step" value="step2">
	</form>
  <body>
</html>
