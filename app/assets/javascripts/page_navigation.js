$(document).ready(function(){
	$(".arrow, .image-next").click(function(e){
		if($(this).attr('href') != "#new_comment") {
			page_url = $(this).attr('href');
			e.preventDefault();
			$.ajax({
				type: "GET",
				dataType: "json",
				url: page_url,
				success: function(data, status){
					history.pushState(null, null, page_url);
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
			});
		}
	});
});