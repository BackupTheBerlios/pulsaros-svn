  <body>
  <div id="wrapper">
  	<div id="logo"></div>
  	<div id="menu">
		<?php echo $menu; ?>
  	</div>
  	<div id="main">
		<div class="box">
			<div id="content">
				<h1>STORAGE OPTIONS</h1>
				<form id="Form" method="post" action="index.php?admin/storage">
					<?php echo $options; ?>
					<div id="result">
						<!-- spanner -->
						<input class="validate['submit']" type="submit" id="submit" value="Install" />
					</div>
				</form>
				<div id="popup" class="PopupContainer" style="width: 560px; height: 150px;">
					<p>Storage configured.<br />
					   <a href="index.php?admin/pool">Next</a>
					</p>
				</div>
			</div>
		</div>
	</div>
  </div>
</body>
</html>
