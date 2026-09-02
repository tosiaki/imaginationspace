import './uppy';

const initializePrivatePageEditor = () => {
  const input = document.querySelector('[data-private-page-upload]');
  const content = document.querySelector('textarea[name="page[content]"]');
  const status = document.querySelector('[data-upload-status]');
  if (!input || !content || !status) return;

  input.addEventListener('change', () => {
    Array.from(input.files).forEach(file => {
      const uploader = window.createDirectUploader({
        autoProceed: true,
        restrictions: {
          allowedFileTypes: input.accept.split(','),
          maxFileSize: 25 * 1024 * 1024,
          maxNumberOfFiles: 1,
        },
      });

      uploader.on('upload-progress', (_file, progress) => {
        const percent = progress.bytesTotal ? Math.round(progress.bytesUploaded / progress.bytesTotal * 100) : 0;
        status.textContent = `Uploading ${file.name}: ${percent}%`;
      });

      uploader.on('upload-error', (_file, error) => {
        status.textContent = `Upload failed: ${error.message}`;
      });

      uploader.on('upload-success', (uploadedFile, response) => {
        const key = window.directUploadObjectKey(response);
        const image = document.createElement('img');
        image.src = URL.createObjectURL(uploadedFile.data);
        image.dataset.fileData = JSON.stringify({
          id: key,
          storage: 'cache',
          metadata: {
            size: uploadedFile.size,
            filename: uploadedFile.name,
            mime_type: uploadedFile.type,
            upload_authorization: window.directUploadAuthorization(key),
          },
        });
        content.value += `${content.value.endsWith('\n') || content.value.length === 0 ? '' : '\n'}${image.outerHTML}`;
        status.textContent = `${file.name} uploaded. Save the page to attach it.`;
      });

      uploader.addFile({ name: file.name, type: file.type, data: file });
    });
    input.value = '';
  });
};

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializePrivatePageEditor);
} else {
  initializePrivatePageEditor();
}
