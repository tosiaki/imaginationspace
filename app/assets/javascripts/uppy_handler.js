function fileUpload(uppyNode, fileInputElement, inPostingBoxElement) {
  var uppyInfoContainer = document.createElement('div');
  uppyInfoContainer.classList.add("uppy-info-container");

  var uppyInnerContainer = document.createElement('div');
  uppyInnerContainer.setAttribute('role', 'status');

  var uppyProgress = document.createElement('progress');
  uppyProgress.max = 100;
  uppyProgress.value = 0;
  uppyProgress.setAttribute('aria-label', 'Upload progress');

  uppyNode.appendChild(uppyInfoContainer);
  uppyInfoContainer.appendChild(uppyInnerContainer);
  uppyInfoContainer.appendChild(uppyProgress);

  var uppyRemoveItem = document.createElement('button');
  uppyRemoveItem.type = 'button';
  uppyRemoveItem.setAttribute('aria-label', 'Remove upload');
  uppyRemoveItem.classList.add("uppy-remove-item");
  var removalTextNode = document.createTextNode("❌");
  uppyRemoveItem.appendChild(removalTextNode);
  uppyNode.appendChild(uppyRemoveItem);

  var uppy;

  uppyRemoveItem.addEventListener('click', function() {
    uppy.cancelAll();
    uppy.destroy();
    var preview_area = uppyNode.parentNode;
    preview_area.removeChild(uppyNode);
    if (preview_area.children.length === 0) {
      preview_area.style.display = "none";
      if(inPostingBoxElement) {
        inPostingBoxElement.classList.add("hidden-label");
      }
    }
  });

  uppy = window.createDirectUploader({
      id: fileInputElement.id,
      autoProceed: true,
      restrictions: {
        allowedFileTypes: fileInputElement.accept.split(','),
      }
    });

  uppy.on('upload-progress', function (_file, progress) {
    uppyProgress.value = progress.bytesTotal ? (progress.bytesUploaded / progress.bytesTotal) * 100 : 0;
    uppyInnerContainer.textContent = 'Uploading…';
  });

  uppy.on('upload-error', function (_file, error) {
    uppyInnerContainer.textContent = 'Upload failed: ' + error.message;
  });

  uppy.on('upload-success', function (file, data) {
    uppyProgress.value = 100;
    uppyInnerContainer.textContent = 'Upload complete';
    var object_key = window.directUploadObjectKey(data);

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
