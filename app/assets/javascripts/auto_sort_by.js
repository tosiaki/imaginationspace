$(document).on('turbolinks:load', function(){
	$(".sort-status-results").on('change', function(e) {
		$(".sort-status-form").submit();
	});
	$('.sort-status-form input[type="submit"]').remove();
});