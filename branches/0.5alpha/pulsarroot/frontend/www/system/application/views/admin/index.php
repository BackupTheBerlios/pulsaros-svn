  <body>
  <div id="wrapper">
  	<div id="logo"></div>
  	<div id="menu">
  		<?php echo $menu; ?>	
  	</div>
  	<div id="main">
		<div class="box">
			<div id="content">
				<h1>OS VERSION</h1>
				<p><?php echo $version;?></p>
				<p>developed by Thomas Brandstetter copyright 2009 </p><br />
				<h1>HARDWARE</h1>
                               	<?php echo $sysinfo; ?>
                               	<h1>STORAGE</h1>
				<?php echo $storage; ?>
				<h1>UPTIME</h1>
				<?php echo $uptime; ?>
			</div>
		</div>
	</div>
  </div>
</body>
</html>
