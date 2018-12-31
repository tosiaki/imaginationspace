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
	$("#resize-link").attr("href", data.resize_url);
}

function load_comic_page_from_url(page_url) {
	$.ajax({
		type: "GET",
		dataType: "json",
		url: page_url.split("?")[0]+".json"+(page_url.split("?")[1] ? "?" + page_url.split("?")[1]: ""),
		success: function(data, status){
			load_comic_page(data);
		}
	});
}

function changeToSmall() {
	$('#image-view,.image-view').removeClass('normal-display');
	$('#image-view,.image-view').addClass('fit-to-screen');
	$('#resize-link').text('Expand to page width');
	$('#resize-link').attr("href", history.state.url.split("?")[0]);
}

function changeToNormal() {
	$('#image-view,.image-view').removeClass('fit-to-screen');
	$('#image-view,.image-view').addClass('normal-display');
	$('#resize-link').text('Shrink to page height');
	$('#resize-link').attr("href", history.state.url+"?size=small");
}

function setSizeFromUrl(pageSize) {
	if (pageSize==="normal") {
		changeToNormal();
	}
	else {
		changeToSmall();
	}
}

function currentSize() {
	if ($('#image-view').hasClass('normal-display')) {
		return "normal";
	}
	else {
		return "small";
	}
}

function load_next_page(page_url) {
	current_comic = history.state.comic;
	history.pushState({ url: page_url, comic: current_comic, pageSize: currentSize() }, null, page_url);
	load_comic_page_from_url(page_url);
}

function setCurrentState(callback) {
	if(typeof history.state.url === 'undefined') {
		current_path = window.location.pathname;
		$.ajax({
			type: "GET",
			dataType: "json",
			url: current_path,
			success: function(data, status){
				history.replaceState({ url: current_path, comic: data.comic, pageSize: currentSize() }, null, current_path);
				callback();
			}
		});
	}
	else {
		callback();
	}
}

function load_article_page(data) {
	$("#article-page-content").html(data.content);
	$("#next-page-link,.next-page-arrow").attr("href", data.next_url);
	$("#previous-page-link,previous-page-arrow").attr("href", data.previous_url);
	$('title').text(data.page_title);
	if (data.title) {
		$(".page-title").text(data.title);
		$(".page-title").show();
	} else {
		$(".page-title").hide();
	}
	if (data.next_url) {
		$("#next-page-link").removeClass("non-arrow-right");
		$("#next-page-link").addClass("arrow-right");
		$("#image-link").addClass("image-next");
		$(".next-page-arrow").removeClass("arrow-placeholder")
	}
	else {
		$("#next-page-link").removeClass("arrow-right");
		$("#next-page-link").addClass("non-arrow-right");
		$("#image-link").removeClass("image-next");
		$("#next-page-link, #image-link").attr("href", "#new_comment")
		$(".next-page-arrow").addClass("arrow-placeholder")
	}
	if (data.previous_url) {
		$("#previous-page-link").removeClass("non-arrow-left");
		$("#previous-page-link").addClass("arrow-left");
		$(".previous-page-arrow").removeClass("arrow-placeholder")
	}
	else {
		$("#previous-page-link").removeClass("arrow-left");
		$("#previous-page-link").addClass("non-arrow-left");
		$(".previous-page-arrow").addClass("arrow-placeholder")
	}
	if (data.next_page_content) {
		$("#next-page-content").html(data.next_page_content);
	}
	if (data.previous_page_content) {
		$("#previous-page-content").html(data.previous_page_content);
	}
	$(".current-page-display").text(data.page_number);
	$("#edit-page-link").attr("href", data.edit_url);
	$("#edit-article-link").attr("href", data.edit_url);
	$("#add-page-before-link").attr("href", data.add_page_before_url);
	$("#add-page-after-link").attr("href", data.add_page_after_url);
	$("#remove-page-link").attr("href", data.remove_page_url);
}

function load_article_page_from_url(page_url) {
	$.ajax({
		type: "GET",
		dataType: "json",
		url: page_url.split("?")[0]+".json"+(page_url.split("?")[1] ? "?" + page_url.split("?")[1]: ""),
		success: function(data, status){
			load_article_page(data);
		}
	});
}

function load_next_article_page(page_url) {
	current_article = history.state.article;
	history.pushState({ url: page_url, article: current_article }, null, page_url);
	load_article_page_from_url(page_url);
}

function setCurrentArticleState(callback) {
	if(typeof history.state.url === 'undefined') {
		current_path = window.location.pathname;
		$.ajax({
			type: "GET",
			dataType: "json",
			url: current_path,
			success: function(data, status){
				history.replaceState({ url: current_path, article: data.article }, null, current_path);
				callback();
			}
		});
	}
	else {
		callback();
	}
}

$(document).on('turbolinks:load', function(){
	$('.page-navigation-select input[type="submit"]').remove();
	if($("#article-identifier").length) {
		$(".page-navigator").click(function(e){
			page_url = $(this).attr('href');

			if($(this).attr('href') != "#new_comment") {
				e.preventDefault();
				setCurrentArticleState(function() {
					load_next_article_page(page_url);
					$('#article-page-content')[0].scrollIntoView({ behavior: "smooth", block: "start" });
				});
			}
		});

		$("body").keydown(function(e) {
			function findPos(obj) {
			    var curtop = 0;
			    if (obj.offsetParent) {
			        do {
			            curtop += obj.offsetTop;
			        } while (obj = obj.offsetParent);
			    return [curtop];
			    }
			}

			window.scroll(0,findPos(document.getElementById("article-page-content")));
			if(e.keyCode === 37) {
				$('#previous-page-link').click();
			}
			else if(e.keyCode === 39) {
				$('#next-page-link').click();
			}
		});

		$("#go_to_page").on('change', function(e) {
			var selectedPage = $("option:selected", this).val();
			page_url = $(this).attr('href');
			$.ajax({
				type: "GET",
				dataType: "json",
				url: page_url,
				data: {go_to_page: selectedPage},
				success: function(data, status){
					load_next_article_page(data.destination_url);
				}
			});
		});
	}

	if($("#comic-identifier").length) {
		$(".page-navigator").click(function(e){
			page_url = $(this).attr('href');

			if($(this).attr('href') != "#new_comment") {
				e.preventDefault();
				setCurrentState(function() {
					load_next_page(page_url);
					$('#image-view')[0].scrollIntoView({ behavior: "smooth", block: "start" });
				});
			}
		});

		$("body").keydown(function(e) {
			function findPos(obj) {
			    var curtop = 0;
			    if (obj.offsetParent) {
			        do {
			            curtop += obj.offsetTop;
			        } while (obj = obj.offsetParent);
			    return [curtop];
			    }
			}

			window.scroll(0,findPos(document.getElementById("image-view")));
			if(e.keyCode === 37) {
				$('#previous-page-link').click();
			}
			else if(e.keyCode === 39) {
				$('#next-page-link').click();
			}
		});

		$("#resize-link").click(function(e) {
			e.preventDefault();
			setCurrentState(function() {
				if($('#image-view').hasClass('normal-display')) {
					changeToSmall();
					history.pushState({ url: history.state.url, comic: history.state.comic, pageSize: currentSize() }, null, history.state.url+"?size=small");
				}
				else {
					changeToNormal();
					history.pushState({ url: history.state.url, comic: history.state.comic, pageSize: currentSize()}, null, history.state.url.split("?")[0]);
				}
			});
		});
	}
});


$(window).on("popstate", function(e) {
	if($("#comic-identifier").length) {
		comic_identifier = Number($('#comic-identifier').text());
		setCurrentState(function() {
			if(typeof e.originalEvent.state.url !== 'undefined' && e.originalEvent.state.comic === comic_identifier ) {
				load_comic_page_from_url(e.originalEvent.state.url);
				setSizeFromUrl(e.originalEvent.state.pageSize);
			}
			else {
				location.reload();
			}
		});
	}

	if($("#article-identifier").length) {
		article_identifier = Number($('#article-identifier').text());
		setCurrentArticleState(function() {
			if(typeof e.originalEvent.state.url !== 'undefined' && e.originalEvent.state.article === article_identifier ) {
				load_article_page_from_url(e.originalEvent.state.url);
			}
			else {
				location.reload();
			}
		});
	}
});