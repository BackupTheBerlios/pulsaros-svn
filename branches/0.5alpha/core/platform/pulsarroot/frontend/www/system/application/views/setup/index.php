  <body>
  <div id="wrapper">
  	<div id="top-header">
		<img src="/images/header.png" />
	</div>
	
	<div id="header"></div>
	
	<div id="main">
		<div id="content_index">
			<div id="left">
				<p>nothing</p>
			</div>
			<div id="right">
				<h1>SYSTEM INSTALLATION</h1><br />
				<p>Welcome to the PulsarOS system installation. In the next steps you need to choose your installation disk
	   	   	   	   and configure your system for the first use.
				</p><br />
				<h1>SYSTEM DISK</h1><br />
				<p>Please choose the right disk to install PulsarOS on your system.</p><br />
				<form id="Form" method="post" action="index.php?setup/install">
					<div id="disk_container">
					<?php foreach($disks as $disk):?>
						<?php print $disk; ?>
					<?php endforeach;?>
					</div>
					<div class='clear'></div>
					<br />
					<h1>SYSTEM CONFIGURATION</h1><br />
					<p>Hostname:<input class="validate['required','alphanum']" type="text" name="hostname" value="" /></p><br />
					<?php foreach($nwcards as $nwcard):?>
						<?php echo $nwcard; ?>
					<?php endforeach;?>
					<p>Using DHCP? <input type="checkbox" name="dhcp" value="y" checked="yes" onclick="showText( this )" onchange="showText( this )"/></p>
					<div id="static">
						IP Address:<input type="text" name="ipaddr" value="" /><br />
						Netmask:<input type="text" name="netmask" value="" /><br />
						Gateway:<input type="text" name="gateway" value="" /><br />
						Nameserver:<input type="text" name="nameserver" value="" /><br />
					</div>
					
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
	
		<div class="clear"></div>
	
		<div id="footer">
			<p>copyright 2009 PulsarOS</p>
		</div>
	</div>
</div>
</body>
</html>