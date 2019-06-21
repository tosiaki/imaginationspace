$(document).on('turbolinks:load', function(){
	$(".sort-status-results, #show_replies").on('change', function(e) {
		$(".sort-status-form").submit();
	});
	$('.sort-status-form input[type="submit"]').remove();
});