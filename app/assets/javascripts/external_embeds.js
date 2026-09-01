document.addEventListener("click", function(event) {
  var button = event.target.closest(".deferred-video-load");
  if (!button) return;

  var source = button.dataset.embedSrc;
  if (!source) return;

  var frame = document.createElement("iframe");
  frame.src = source;
  frame.title = button.dataset.embedTitle || "External video";
  frame.loading = "lazy";
  frame.allow = "encrypted-media; picture-in-picture";
  frame.referrerPolicy = "strict-origin-when-cross-origin";
  frame.allowFullscreen = true;

  button.parentNode.replaceWith(frame);
});
