  <body>
  <div id="wrapper">
  	<div id="logo"></div>
  	<div id="menu">
  		<?php echo $menu; ?>
  	</div>
  	<div id="main">
		<div class="box">
			<div id="content">
				<h1>STORAGE</h1>
				<?php echo $storage; ?>
				<p><a href='' id='addform'><img src='/images/delete.png' alt='delete' /></a></p>
				<div id='formcontainer'>
				<form id="Form" method="post" action="index.php?admin/pool">
					<div>
				   		<p>Delete Pool? All your data on the disk will be DELETED!<input type="checkbox" name="storage" value="y" /></p>
				   </div><br />
				   <div id="result">
						<!-- spanner -->
						<input class="validate['submit']" type="submit" id="submit" value="Proceed" />
				   </div>
				</form>
				<div id="popup" class="PopupContainer" style="width: 560px; height: 150px;">
					<p>Pool deleted.<br />
					   <a href="index.php?admin/pool">Next</a>
					</p>
				</div>
				</div>
			</div>
		</div>
	</div>
  </div>
</body>
</html>
