  <body>
  <div id="wrapper">
  	<div id="top-header">
		<img src="/images/header.png" />
	</div>
	
	<div id="header">
	</div>
	
	<div id="main">
	<div id="content_index">
		<div id="left">
			<p>nothing</p>
		</div>
		<div id="right">
		<h1>SYSTEM INSTALLATION</h1>
		<br />
		<p>Welcome to the PulsarOS system installation. In the next steps you need to choose your installation disk
	   	   and configure your system for the first use.
		</p>
		<br />
		<h1>SYSTEM DISK</h1>
		<br />
		<p>Please choose the right disk to install PulsarOS on your system.</p>
		<br />
		<form id="setupForm" method="post" action="index.php?setup/install">
			<?php foreach($disk as $diskname):?>
			<input type="radio" name="disk" value=<?php echo $diskname[0];?> /> <?php echo "Disk: $diskname[0] Size: $diskname[1]";?><br />
			<?php endforeach;?>
			<p>All data on disk will be destroyed!</p>
			<br />
			<h1>SYSTEM CONFIGURATION</h1>
			<br />
			Hostname:<input type="text" name="hostname" value="" /><br />
			<?php foreach($nwcard as $nwname):?>
			<input type="radio" name="nwcard" value=<?php echo $nwname;?> /> <?php echo "Interface: $nwname";?><br />
			<?php endforeach;?>
			<p>Choose your network card for configuration</p><br />
			<p>Configure your network manually? <input type="checkbox" name="dhcp" value="y" onclick="showText( this )" onchange="showText( this )"/></p>
			<div id="static">
				IP Address:<input id="ipaddr" type="text" name="ipaddr" value="" /><br />
				Netmask:<input type="text" name="netmask" value="" /><br />
				Gateway:<input type="text" name="gateway" value="" /><br />
				Nameserver:<input type="text" name="nameserver" value="" /><br />
			</div>
			<input type="submit" id="submit" value="submit" />
		</form>
		<div id="log">
			<h3>Ajax Response</h3>
			<div id="log_res"><!-- spanner --></div>
		</div>
	</div>
	</div>
	<div class="clear"></div>
	<div id="footer">
		<p>copyright 2009 PulsarOS</p>
	</div>
</div>
</div>
		<script type="text/javascript"> 
			function showText( b ) {
				// {b} is a reference to the button
				// get a reference to the button's parent form
				var f = b.parentNode;
				var inputs = f.getElementsByTagName( 'INPUT' );
				var last = inputs.length;
				var anyChecked = false;
				for (var i = 0; i < last; i++) {
					if ('checkbox' == inputs[i].type) {
						anyChecked = anyChecked || inputs[i].checked;
					}
					var d = document;
					var tf = d.getElementById( 'static' );
					if (anyChecked) {
						tf.style.display = 'block';
					}
					else {
						tf.style.display = 'none';
					}
				}
			}
			
			window.addEvent('domready', function() {
				$('setupForm').addEvent('submit', function(e) {
					//Prevents the default submit event from loading a new page.
					e.stop();
					//Empty the log and show the spinning indicator.
					var log = $('log_res').empty().addClass('ajax-loading');
					//Set the options of the form's Request handler. 
					//("this" refers to the $('setupForm') element).
					this.set('send', {onComplete: function(response) { 
						log.removeClass('ajax-loading');
						log.set('html', response);
					}});
					//Send the form.
					this.send();
				});
			});
		</script>
  <body>
</html>