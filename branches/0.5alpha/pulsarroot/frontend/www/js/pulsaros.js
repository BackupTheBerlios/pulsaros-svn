// Check Form elements
window.addEvent('domready', function() {
	new FormCheck('Form');
	
	//Submit Form with AJAX                       
	$('Form').addEvent('submit', function(f) {    
		//Prevents the default submit event from loading a new page.
		f = new Event(f).stop();                                    
		//Empty the log and show the spinning indicator.            
		var log = $('result').empty().addClass('ajax-loading');     
		//Set the options of the form's Request handler.            
		this.set('send', {onComplete: function(response) {          
			log.removeClass('ajax-loading');                    
			//log.set('html', response);                        
			showPopUp('popup');                                 
		}});                                                        
		// Send this form                                           
		this.send();                                                
	});
	
	//slide form	
	var slide = new Fx.Slide('formcontainer').hide();
	$('addform').addEvent('click', function(e) {
		e = new Event(e).stop();
		slide.toggle();
	});	
	
	// PopUP for important steps
	var options = {
        	modalStyle: { opacity: 0.2 }
        	, animate: true
        	, onWindowClose: this.CloseRemovePopup
	};

	function showPopUp(grabElementId) {
        	CTModalizer.grab(
        	grabElementId
        	, options);
	}

	function CloseRemovePopup() {
	}
	
	new MooSwitch('switch');
});

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
			tf.style.display = 'none';
		}
		else {
			tf.style.display = 'block';
		}
	}
}
