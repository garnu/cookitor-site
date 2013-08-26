function initializeToolbar(){
  $('#raw').hide();
  $('#highlight-button').click(function() {
    $('#raw').hide();
    $('#raw-button').removeClass('selected');
    $('#highlight-button').addClass('selected');
    $('#highlighted').fadeIn();
  });
  $('#raw-button').click(function() {
    $('#highlighted').hide();
    $('#highlight-button').removeClass('selected');
    $('#raw-button').addClass('selected');
    $('#raw').fadeIn();
  });
}

$(document).ready(function() {
	initializeToolbar();
  $('#processing-form .decode').click(function(e) {
		$.ajax({
		  type: 'POST',
		  url: $('#processing-form').attr('action'),
		  data: {
		  	content: $('#content').val(),
        key_value: $('#key_value').val()
		  },
		  success: function(data) {
		  	$('#response').html(data);
		  	$('#response').removeClass('error');
		  	initializeToolbar();
		  },
		  error: function(jqXHR, textStatus, errorThrown) {
		  	$('#response').html(jqXHR.responseText);
		  	$('#response').addClass('error');
		  }
		});
		e.preventDefault();
	});
});
