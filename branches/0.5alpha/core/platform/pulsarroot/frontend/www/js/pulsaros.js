// Check Form elements
window.addEvent('domready', function() {
	new FormCheck('Form');
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

// Submit Form with AJAX		
window.addEvent('domready', function() {
	$('Form').addEvent('submit', function(e) {
		//Prevents the default submit event from loading a new page.
		e.stop();
		//Empty the log and show the spinning indicator.
		var log = $('result').empty().addClass('ajax-loading');
		//Set the options of the form's Request handler.
		//("this" refers to the $('setupForm') element).
		this.set('send', {onComplete: function(response) {
			log.removeClass('ajax-loading');
			//log.set('html', response);
			showPopUp('popup');	
		}});
		//Send the form.
		this.send();
	});
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