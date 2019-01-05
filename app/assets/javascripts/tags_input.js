function enableTagsInput(element) {
	var tagify_elements = element.querySelectorAll("[data-tagify]");
	if (element.getElementsByClassName('tagify').length === 0) {
		Array.prototype.forEach.call(tagify_elements, function(form_element) {
			var tagify = new Tagify(form_element, {whitelist:[]});
			var controller;

			tagify.on('input', function (e){
			  var value = e.detail;
			  tagify.settings.whitelist.length = 0; // reset the whitelist

			  controller && controller.abort();
			  controller = new AbortController();

			  fetch_location = window.location.origin + "/article_tags?value=" + encodeURIComponent(value);
			  if(context = form_element.dataset.context) {
			  	fetch_location += "&context=" + context;
			  }

			  fetch(fetch_location, {
			  	signal: controller.signal,
			    headers: {
			      'Accept': 'application/json'
			    }
			  }).then(response => response.json())
			    .then(function(new_whitelist){
			      tagify.settings.whitelist = new_whitelist;
			      tagify.dropdown.show.call(tagify, value); // render the suggestions dropdown
			    });
			});
		});

		$(".submit-button, #search").click(function(e) {
			Array.prototype.forEach.call(tagify_elements, function(element) {
				if(value = element.value) {
					element.value = JSON.parse(value).map(function(a) {return a.value;}).join(',');
				}
			});
		});
	}
}

$(document).on('turbolinks:load', function() {
	enableTagsInput(document);
});