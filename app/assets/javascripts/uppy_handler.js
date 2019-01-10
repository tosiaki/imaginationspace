function fileUpload(uppyNode, fileInputElement, inPostingBoxElement) {
  var uppyInfoContainer = document.createElement('div');
  uppyInfoContainer.classList.add("uppy-info-container");

  var uppyInnerContainer = document.createElement('div');

  uppyNode.appendChild(uppyInfoContainer);
  uppyInfoContainer.appendChild(uppyInnerContainer);

  var uppyRemoveItem = document.createElement('div');
  uppyRemoveItem.classList.add("uppy-remove-item");
  var removalTextNode = document.createTextNode("❌");
  uppyRemoveItem.appendChild(removalTextNode);
  uppyNode.appendChild(uppyRemoveItem);

  uppyRemoveItem.addEventListener('click', function() {
    preview_area = uppyNode.parentNode;
    preview_area.removeChild(uppyNode);
    if (preview_area.children.length === 0) {
      preview_area.style.display = "none";
      if(inPostingBoxElement) {
        inPostingBoxElement.classList.add("hidden-label");
      }
    }
  });

  var uppy = Uppy.Core({
      id: fileInputElement.id,
      autoProceed: true,
      restrictions: {
        allowedFileTypes: fileInputElement.accept.split(','),
      }
    })
    .use(Uppy.Informer, {
      target: uppyInnerContainer,
    })
    .use(Uppy.ProgressBar, {
      target: uppyInnerContainer,
    });

  uppy.use(Uppy.AwsS3, {
    serverUrl: '/', // will call Shrine's presign endpoint on `/s3/params`
  });

  uppy.on('upload-success', function (file, data) {
    object_key = file.meta['key'].match(new RegExp("^" + fileInputElement.dataset.prefix + "\\/(.+)"))[1];

    // construct uploaded file data in the format that Shrine expects
    var uploadedFileData = JSON.stringify({
      id: object_key, // object key without prefix
      storage: 'cache',
      metadata: {
        size:      file.size,
        filename:  file.name,
        mime_type: file.type,
      }
    });

    // show image preview
    var newImagePreview = document.createElement('img');
    newImagePreview.src = URL.createObjectURL(file.data);
    newImagePreview.classList.add("preview-image");
    uppyNode.appendChild(newImagePreview);

    var newHiddenInput = document.createElement('input');
    newHiddenInput.type = "hidden";
    newHiddenInput.value = uploadedFileData;
    newHiddenInput.name = fileInputElement.name;
    uppyInfoContainer.appendChild(newHiddenInput);
  });

  return uppy;
}

function useUppy(element){
  Array.from(element.getElementsByClassName("file-upload-label")).forEach(function (labelElement) {
    labelElement.classList.remove("hidden-label");
  });

  Array.from(element.getElementsByClassName("new-post-pictures")).forEach(function (fileInputElement) {
    fileInputElement.style.display = 'none';
    inPostingBoxElement = fileInputElement.closest('.file-input-area').getElementsByClassName("new-pages-option-label")[0];
    if(inPostingBoxElement) {
      inPostingBoxElement.classList.add('hidden-label');
    }

    (function(inPostingBoxElement) {
      fileInputElement.addEventListener('change', function(event) {
        if (inPostingBoxElement) {
          inPostingBoxElement.classList.remove('hidden-label');
        }

        previewArea = fileInputElement.closest(".file-input-area").getElementsByClassName('preview-area')[0];
        previewArea.style.display = 'flex';

        Array.from(fileInputElement.files).forEach(function (file) {
          var newImageContainer = document.createElement('div');
          newImageContainer.classList.add("image-preview-container");

          previewArea.appendChild(newImageContainer);

          uppy = fileUpload(newImageContainer, fileInputElement, inPostingBoxElement);
          uppy.addFile({name: file.name, type: file.type, data: file});
        });

        fileInputElement.value = '';
      });
    })(inPostingBoxElement);
  });
}

$(document).on('turbolinks:load', function() {
  useUppy(document);
});