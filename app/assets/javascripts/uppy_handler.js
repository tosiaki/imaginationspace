function fileUpload(uppyNode) {
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
    uppyNode.parentNode.removeChild(uppyNode);
  });

  var uppy = Uppy.Core({
      // id: fileInput.id,
      autoProceed: true,
      restrictions: {
        allowedFileTypes: document.getElementById('new_page_picture').accept.split(','),
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
    object_key = file.meta['key'].match(/^cache\/(.+)/)[1];

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
    newHiddenInput.name = "new_page[picture][]";
    uppyInfoContainer.appendChild(newHiddenInput, fileInput);
  });

  return uppy;
}

$(document).on('turbolinks:load', function(){
  fileInput = document.getElementById('new_page_picture');
  previewArea = document.getElementById('preview-area');
  fileInput.style.display = 'none';
  Array.from(document.getElementsByClassName("file-upload-label")).forEach(function (element) {
    element.style.display = "flex";
  });

  var fileInputLabel = document.createElement('label');

  fileInput.addEventListener('change', function(event) {
    previewArea.style.display = 'flex';

    Array.from(fileInput.files).forEach(function (file) {
      var newImageContainer = document.createElement('div');
      newImageContainer.classList.add("image-preview-container");

      previewArea.appendChild(newImageContainer);

      uppy = fileUpload(newImageContainer);
      uppy.addFile({name: file.name, type: file.type, data: file});
    });

    fileInput.value = '';
  });
});