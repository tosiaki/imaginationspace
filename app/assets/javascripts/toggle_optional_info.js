function toggleOptionalInfo(element){
	if($(element).find('.toggle-optional-info-link').length === 0) {
		$(element).find('.optional-info-header').append(
			$('<span/>').addClass('toggle-optional-info-link').html('(Show 🔽)')
		);
	}
	$(element).find('.optional-info-area').hide();
	$(element).find('.toggle-optional-info-link').click(function(event) {
		infoArea = $(this).closest(".additional-options-list").find(".optional-info-area");
		if(infoArea.is(':hidden')) {
			infoArea.slideDown();
			$(this).text('(Hide 🔼)');
		} else {
			infoArea.slideUp();
			$(this).text('(Show 🔽)');
		}
	});
}

$(document).on('turbolinks:load', function() {
	toggleOptionalInfo(document);

	$('input[type=radio][name="tags[media]"]').change(function() {
		checkbox = $(this.closest('form.new_article')).find('input.new-page-option');
		if (this.value == 'Drawing(s)' || this.value == 'Comic') {
			checkbox.prop("checked", true);
		} else {
			checkbox.prop("checked", false);
		}
	});
});