function load_comic_page(data) {
	$("#image-view").attr("src", data.drawing_url);
	$("#next-page-link,#image-link").attr("href", data.next_url);
	$("#previous-page-link").attr("href", data.previous_url);
	if (data.next_url) {
		$("#next-page-link").removeClass("non-arrow-right");
		$("#next-page-link").addClass("arrow-right");
		$("#image-link").addClass("image-next");
	}
	else {
		$("#next-page-link").removeClass("arrow-right");
		$("#next-page-link").addClass("non-arrow-right");
		$("#image-link").removeClass("image-next");
		$("#next-page-link, #image-link").attr("href", "#new_comment")
	}
	if (data.previous_url) {
		$("#previous-page-link").removeClass("non-arrow-left");
		$("#previous-page-link").addClass("arrow-left");
	}
	else {
		$("#previous-page-link").removeClass("arrow-left");
		$("#previous-page-link").addClass("non-arrow-left");
	}
	$("#current-page-display").text(data.page_number);
	if(data.big_page) {
		$("#big-page-note").removeClass("inapplicable");
		$("#full-picture-link").attr("href", data.full_url);
		$("#width-indicator").text(data.dimensions.width);
		$("#height-indicator").text(data.dimensions.height);
	}
	else {
		$("#big-page-note").addClass("inapplicable");
	}
	$("#add-page-link").attr("href", data.add_page_url);
	$("#replace-page-link").attr("href", data.replace_page_url);
	$("#delete-page-link").attr("href", data.delete_page_url);
}

function load_comic_page_from_url(page_url) {
	$.ajax({
		type: "GET",
		dataType: "json",
		url: page_url,
		success: function(data, status){
			load_comic_page(data);
		}
	});
}

$(document).on('ready turbolinks:load', function(){
	$(".page-navigator").click(function(e){
		if($(this).attr('href') != "#new_comment") {
			e.preventDefault();
			if(typeof history.state.url === 'undefined') {
				history.replaceState({ url: window.location.pathname }, null, window.location.pathname);
			}
			page_url = $(this).attr('href');
			history.pushState({ url: page_url }, null, page_url);
			load_comic_page_from_url(page_url);
		}
	});

	$("body").keydown(function(e) {
		if(e.keyCode == 37) {
			$('#previous-page-link').click();
		}
		else if(e.keyCode == 39) {
			$('#next-page-link').click();
		}
	});

	$(window).on("popstate", function(e) {
		if(typeof e.originalEvent.state.url !== 'undefined') {
			load_comic_page_from_url(e.originalEvent.state.url);
		}
	})
});