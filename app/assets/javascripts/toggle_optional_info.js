$(document).on('turbolinks:load', function(){
	if($('.toggle-optional-info-link').length === 0) {
		$('.optional-info-header').append(
			$('<span/>').addClass('toggle-optional-info-link').html('(Show 🔽)')
		);
	}
	$('.optional-info-area').hide();
	$('.toggle-optional-info-link').click(function(e) {
		if($('.optional-info-area').is(':hidden')) {
			$('.optional-info-area').slideDown();
			$('.toggle-optional-info-link').text('(Hide 🔼)');
		} else {
			$('.optional-info-area').slideUp();
			$('.toggle-optional-info-link').text('(Show 🔽)');
		}
	});
});