$(document).on('turbolinks:load', function(){
	$(".follow-action-link").click(function(e) {
		e.preventDefault();
		e.stopPropagation();

		if ($(".follow-action-link").text() === 'Follow') {
			$(".follow-action-link").text('Unfollow');
			$.ajax({
				type: "POST",
				dataType: "json",
				url: $(this).attr('href'),
				success: function(data, status){
					$(".current-followers-count").text(data.current_followers);
					$(".follow-action-link").attr("href", data.new_link);
					if($("#follower-count-area").is(":hidden")) {
						$("#follower-count-area").fadeIn();
					}
				}
			});
		} else if ($(".follow-action-link").text() === 'Unfollow'){
			$(".follow-action-link").text('Follow');
			$.ajax({
				type: "DELETE",
				dataType: "json",
				url: $(this).attr('href'),
				success: function(data, status){
					$(".current-followers-count").text(data.current_followers);
					$(".follow-action-link").attr("href", data.new_link);
					if($("#follower-count-area").is(":visible") && data.current_followers === 0) {
						$("#follower-count-area").fadeOut();
					}
				}
			});
		}
	});

	$(".status-listing-follow-button").click(function(e) {
		e.preventDefault();
		e.stopPropagation();
		documentElement = $(this);
		$.ajax({
			type: "POST",
			dataType: "json",
			url: documentElement.attr('href'),
			success: function(data, status){
				$('.status-follow-action[data-user-id="' + documentElement.data('link-user-id') + '"]').remove();
			}
		});
	})
});