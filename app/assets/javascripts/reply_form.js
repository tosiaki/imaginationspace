$(document).on('turbolinks:load', function(){
  var reply_buttons = document.getElementsByClassName("reply-button");
  Array.prototype.forEach.call(reply_buttons, function(reply_button) {
    reply_button.addEventListener("click", function(event) {
      event.preventDefault();

      listElement = reply_button.closest("div.status-quotation, li.reply, li.status");
      siblingSelection = $(listElement.nextElementSibling);

      if (siblingSelection.is(":hidden")) {
        siblingSelection.slideDown();
      } else {
        siblingSelection.slideUp();
      }

      // xhttp = new XMLHttpRequest();
      // xhttp.open("GET", reply_button.dataset.replyformpath);
      // xhttp.send();
      // xhttp.onreadystatechange = function() {
      //   if (this.readyState == 4 && this.status == 200) {
      //     listElement = reply_button.closest("li.reply");
      //     var newReplyArea = document.createElement('li');
      //     listElement.parentNode.insertBefore(newReplyArea, listElement.nextSibling);
      //     newReplyArea.innerHTML = JSON.parse(xhttp.responseText).result_template;
      //     enableTagsInput(newReplyArea);
      //     toggleOptionalInfo(newReplyArea);
      //     useUppy(newReplyArea);
      //   }
      // }
    });
  });

});