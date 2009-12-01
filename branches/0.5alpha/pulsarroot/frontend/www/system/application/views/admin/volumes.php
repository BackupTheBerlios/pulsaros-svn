  <body>
  <div id="wrapper">
  	<div id="logo"></div>
  	<div id="menu">
  		<?php echo $menu; ?>
  	</div>
  	<div id="main">
		<div class="box">
			<div id="content">
				<h1>VOLUMES</h1>
				<div class='volumes'>
				   		<div class='name'>VOLUME NAME</div>
				   		<div class='stat'>STATUS</div>
				   		<div class='desc'>DESCRIPTION</div>
				</div>
				<div id="container">
					<?php echo $volumes; ?>
					<form id="Form" method="post" action="index.php?admin/volumes">
					<div class='clear'></div>
				   		<p><a href='' id='addform'><img src='/images/add.png' alt='add' /></a></p>
				   		<div id='formcontainer'>
				   			<p>
								<label class='text'>Name:</label>
								<input type='text' name='volname' value='' />
							</p>
							<p>
								<label class='text'>Description:</label>
						  		<input type='text' name='voldesc' value='' />
							</p>
							<div id="result">
								<!-- spanner -->
								<input class="validate['submit']" type="submit" id="submit" value="add" />
							</div>
				 		</div>
					</form>
				</div>
				<div id="popup" class="PopupContainer" style="width: 560px; height: 150px;">
					<p>Volume added.<br />
				   	<a href="index.php?admin/volume">Next</a>
					</p>
				</div>
			</div>
		</div>
	</div>
  </div>
</body>
</html>