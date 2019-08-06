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

function isElementInViewport(el) {
    if (typeof jQuery === "function" && el instanceof jQuery) {
        el = el[0];
    }

    var rect = el.getBoundingClientRect();

    return (
        rect.top <= (window.innerHeight || document.documentElement.clientHeight) &&
        rect.bottom >= 0
    );
}

function clickNextPage(targetArticle) {
	nextPageLinkElement = $(targetArticle).find('.next-page-link');
	if (nextPageLinkElement.length) {
		e.preventDefault();
		nextPageLinkElement[0].click();
	}
}

function turn_images_to_links(targetArticle, link) {
	articleElement = $(targetArticle).find('.article-page-content');
	addSeeMore(articleElement[0]);
	$(targetArticle).find('.article-context a:has(img)').click(function(e) {
		if (articleElement.hasClass('shortened-article') && $(targetArticle).find('.see-more-link').length) {
			e.preventDefault();
			$(targetArticle).find('.see-more-link').click();
		} else {
			clickNextPage(targetArticle);
		}
	});
}

function load_article_page(data, target_article) {
	article_context = $(target_article).find('.article-context')[0];
	next_page_link = $(target_article).find('.next-page-link')[0];
	previous_page_link = $(target_article).find('.previous-page-link')[0];
	next_page_arrow = $(target_article).find('.next-page-arrow')[0];
	previous_page_arrow = $(target_article).find('.previous-page-arrow')[0];
	page_title = $(target_article).find('.page-title')[0];

	previous_page_content = $(target_article).find('.previous-page-content')[0];
	next_page_content = $(target_article).find('.next-page-content')[0];

	$(article_context).html(data.content);
	$(next_page_link).attr("href", data.next_url);
	$(previous_page_link).attr("href", data.previous_url);

	if($("#article-identifier").length) {
		$('title').text(data.page_title);
	}
	if (data.title) {
		$(page_title).text(data.title);
		$(page_title).show();
	} else {
		$(page_title).hide();
	}
	if (data.next_url) {
		$(next_page_link).removeClass("non-arrow-right");
		$(next_page_link).addClass("arrow-right");
		$(next_page_arrow).removeClass("arrow-placeholder")
	}
	else {
		$(next_page_link).removeClass("arrow-right");
		$(next_page_link).addClass("non-arrow-right");
		$(next_page_link).attr("href", "#new_comment")
		$(next_page_arrow).addClass("arrow-placeholder")
	}
	if (data.previous_url) {
		$(previous_page_link).removeClass("non-arrow-left");
		$(previous_page_link).addClass("arrow-left");
		$(previous_page_arrow).removeClass("arrow-placeholder")
	}
	else {
		$(previous_page_link).removeClass("arrow-left");
		$(previous_page_link).addClass("non-arrow-left");
		$(previous_page_arrow).addClass("arrow-placeholder")
	}
	if (data.next_page_content) {
		$(next_page_content).html(data.next_page_content);
	}
	if (data.previous_page_content) {
		$(previous_page_content).html(data.previous_page_content);
	}
	$($(target_article).find('.current-page-display')[0]).text(data.page_number);
	$($(target_article).find(".go-to-page")[0]).val(data.page_number);
	$($(target_article).find(".edit-page-link")[0]).attr("href", data.edit_url);
	$($(target_article).find(".edit-article-link")[0]).attr("href", data.edit_url);
	$($(target_article).find(".add-page-before-link")[0]).attr("href", data.add_page_before_url);
	$($(target_article).find(".add-page-after-link")[0]).attr("href", data.add_page_after_url);
	$($(target_article).find(".remove-page-link")[0]).attr("href", data.remove_page_url);
	turn_images_to_links(target_article, $(next_page_link).attr("href"));
}

function load_article_page_from_url(page_url, target_article) {
	$.ajax({
		type: "GET",
		dataType: "json",
		url: page_url.split("?")[0]+".json"+(page_url.split("?")[1] ? "?" + page_url.split("?")[1]: ""),
		success: function(data, status){
			load_article_page(data, target_article);
		}
	});
}

function load_next_article_page(page_url, target_article) {
	current_article = history.state.article;
	// history.pushState({ url: page_url, article: current_article }, null, page_url);
	load_article_page_from_url(page_url, target_article);
}

function setCurrentArticleState(callback) {
	if(typeof history.state.url === 'undefined') {
		current_path = window.location.pathname;
		/*
		$.ajax({
			type: "GET",
			dataType: "json",
			url: current_path,
			success: function(data, status){
				history.replaceState({ url: current_path, article: data.article }, null, current_path);
				callback();
			}
		});
		*/
		callback();
	}
	else {
		callback();
	}
}

function load_listener(event, url) {
	event.preventDefault();
	setCurrentArticleState(function() {
		load_next_article_page(url, event.target.closest('.article-page-display'));
		// $('#article-page-content')[0].scrollIntoView({ behavior: "smooth", block: "start" });
	});
}

$(document).on('turbolinks:load', function(){
	$('.page-navigation-select input[type="submit"]').remove();
	if($("#article-identifier, .article-identifier").length) {
		// turn_images_to_links();

		$(".page-navigator").click(function(e){
			page_url = $(this).attr('href');

			if($(this).attr('href') != "#new_comment") {
				load_listener(e, page_url);
			}
		});

		$(".go-to-page").on('change', function(e) {
			var selectedPage = $("option:selected", this).val();
			displayTarget = e.target.closest('.article-page-display');
			page_url = $(displayTarget).find('.article-page-link').attr('href');
			setCurrentArticleState(function() {
				$.ajax({
					type: "GET",
					dataType: "json",
					url: page_url,
					data: {go_to_page: selectedPage},
					success: function(data, status){
						load_next_article_page(data.destination_url, displayTarget );
					}
				});
			});
		});

		$("body").keydown(function(e) {
			function findPos(obj) {
			    var curtop = 0;
			    if (obj.offsetParent) {
			        do {
			            curtop += obj.offsetTop;
			        } while (obj = obj.offsetParent);
			    return [curtop-5];
			    }
			}

			if(e.keyCode === 37) {
				var first = true;
				$('.previous-page-link').each(function() {
					if (isElementInViewport(this) && first) {
						first = false;
						this.click();
						window.scroll(0,findPos(this.closest('.article-page-content')));
					}
				});
			}
			else if(e.keyCode === 39) {
				var first = true;
				$('.next-page-link').each(function() {
					if (isElementInViewport(this) && first) {
						first = false;
						this.click();
						window.scroll(0,findPos(this.closest('.article-page-content')));
					}
				});
			}
		});

		$(window).on("popstate", function(e) {
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
	}

	$(".status-list .article-context a:has(img)").click(function(e) {
		eventTarget = $(event.target);
		statusElement = eventTarget.closest('.status');
		articleElement = statusElement.find('.article-content-container');
		if (articleElement.hasClass('shortened-article')) {
			e.preventDefault();
			statusElement.find('.see-more-link').click();
		} else {
			nextPageLinkElement = statusElement.find('.next-page-link');
			if (nextPageLinkElement.length) {
				e.preventDefault();
				nextPageLinkElement[0].click();
			}
		}
	});


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
		});
	}
});