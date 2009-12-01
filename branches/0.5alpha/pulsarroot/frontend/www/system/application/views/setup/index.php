  <body>
  <div id="wrapper">
  	<div id="logo"></div>
  	<div id="menu">
  		<p class="bold">Menu</p>
  		<p>Setup</p>
  	</div>
  	<div id="main">
		<div class="box">
			<div id="content">
				<h1>SYSTEM INSTALLATION</h1>
				<p>Welcome to the PulsarOS system installation. In the next steps you need to choose your installation disk
  	   	   		   and configure your system for the first use.
				</p><br />
				<h1>SYSTEM DISK</h1>
				<p>Please choose the right disk to install PulsarOS on your system.</p>
				<form id="Form" method="post" action="index.php?setup/install">
					<div id="disk_container">
						<?php foreach($disks as $disk):?>
							<?php print $disk; ?>
						<?php endforeach;?>
					</div>
					<div class='clear'></div><br />
					<h1>SYSTEM CONFIGURATION</h1>
					<p>
					  <label class='text'>Hostname:</label>
					  <input class="validate['required','alphanum']" type="text" name="hostname" value="" />
					</p>
					<?php foreach($nwcards as $nwcard):?>
						<?php echo $nwcard; ?>
					<?php endforeach;?>
					<p>Using DHCP? <input type="checkbox" name="dhcp" value="y" checked="yes" onclick="showText( this )" onchange="showText( this )"/></p><br />
					<div id="static">
						<p>
						  <label class='text'>IP Address:</label>
						  <input type="text" name="ipaddr" value="" />
						</p>
						<p>
						  <label class='text'>Netmask:</label>
						  <input type="text" name="netmask" value="" />
						</p>
						<p>
						  <label class='text'>Gateway:</label>
						  <input type="text" name="gateway" value="" />
						</p>
						<p>
						  <label class='text'>Nameserver:</label>
						  <input type="text" name="nameserver" value="" />
						</p>
					</div><br />
					<div id="result">
						<!-- spanner -->
						<input class="validate['submit']" type="submit" id="submit" value="Install" />
					</div>
				</form>
				<div id="popup" class="PopupContainer" style="width: 560px; height: 150px;">
					<p>Your system is installed now. Please reboot it and remove any setup dvd's/cd's or sticks.</p>
				</div>
			</div>
		</div>
	</div>
  </div>
</body>
</html>
