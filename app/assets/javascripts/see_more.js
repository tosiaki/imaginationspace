$(document).on('turbolinks:load', function(){
	articleEntries = document.getElementsByClassName('article-content-container');
	Array.prototype.forEach.call(articleEntries, function(articleEntry){
		addSeeMore(articleEntry);

		articleImages = articleEntry.getElementsByTagName('img')
		Array.prototype.forEach.call(articleImages, function(articleImage) {
			if (!articleImage.complete) {
				articleImage.addEventListener('load', function() {
					addSeeMore(articleEntry);
				});
			}
		});
	});
});


function addSeeMore(articleEntry) {
	if (articleEntry.scrollHeight > articleEntry.clientHeight) {
		var seeMoreText = document.createTextNode("See more");
		var anchor = document.createElement('a');
		anchor.appendChild(seeMoreText);
		anchor.href = "#";
		var seeMoreContainer = document.createElement('div');
		seeMoreContainer.classList.add('see-more-link');
		seeMoreContainer.appendChild(anchor);
		articleEntry.parentNode.insertBefore(seeMoreContainer, articleEntry.nextSibling);

		seeMoreContainer.addEventListener('click', function(event) {
			event.preventDefault();
			articleContainer = seeMoreContainer.previousSibling;
			if (articleContainer.classList.contains("shortened-article")) {
				articleContainer.classList.remove('shortened-article');
				seeMoreText.nodeValue = "See less";
			} else {
				articleContainer.classList.add('shortened-article');
				seeMoreText.nodeValue = "See more";
			}
		});
	}
}