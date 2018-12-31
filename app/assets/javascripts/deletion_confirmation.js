$(document).on('turbolinks:load', function(){
	$(".deletion-link").click(function(){
		if (!confirm("Are you sure?")) {
			return false;
		}
	});
});