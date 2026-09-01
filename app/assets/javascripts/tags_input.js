function enableTagsInput(element) {
	var tagify_elements = element.querySelectorAll("[data-tagify]");
	if (element.getElementsByClassName('tagify').length === 0) {
		Array.prototype.forEach.call(tagify_elements, function(form_element) {
			var tagify = new Tagify(form_element, {
				whitelist: [],
				originalInputValueFormat: function(values) {
					return values.map(function(tag) { return tag.value; }).join(',');
				}
			});
			var controller;

			tagify.on('input', function (e){
			  var value = e.detail.value;
			  tagify.whitelist = null;

			  controller && controller.abort();
			  controller = new AbortController();

			  var fetch_location = new URL('/article_tags', window.location.origin);
			  fetch_location.searchParams.set('value', value);
			  var context = form_element.dataset.context;
			  if(context) {
				fetch_location.searchParams.set('context', context);
			  }

			  fetch(fetch_location, {
			  	signal: controller.signal,
			    headers: {
			      'Accept': 'application/json'
			    }
			  }).then(response => response.json())
			    .then(function(new_whitelist) {
			      tagify.whitelist = new_whitelist;
			      tagify.dropdown.show(value);
			    })
			    .catch(function(error) {
			      if (error.name !== 'AbortError') throw error;
			    });
			});
		});
	}
}

$(document).on('turbolinks:load', function() {
	enableTagsInput(document);
});
