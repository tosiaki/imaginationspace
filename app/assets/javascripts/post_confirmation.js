$(document).on('turbolinks:load', function(){
	if($(".new_article, #new_page, .edit_article").length) {
		$("#new_article :input, #new_page :input, .edit_article :input").on("change", setBeforeUnload);
		$(".javascript-editor").on("input", setBeforeUnload)
	}
	$(".submit-button").click(function(e) {
		window.onbeforeunload = null;
	});
});

function setBeforeUnload(e) {
	window.onbeforeunload = function() {
		return true;
	}
}