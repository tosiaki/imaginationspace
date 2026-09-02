import './uppy';

const csrfToken = () => document.querySelector('meta[name="csrf-token"]')?.content;

const initializeUploadSmokeTest = () => {
  const input = document.querySelector('[data-upload-smoke-test]');
  const status = document.querySelector('[data-upload-smoke-status]');
  if (!input || !status) return;

  input.addEventListener('change', () => {
    const file = input.files[0];
    if (!file) return;

    input.disabled = true;
    status.textContent = `Uploading ${file.name}…`;
    const uploader = window.createDirectUploader({
      autoProceed: true,
      restrictions: {
        allowedFileTypes: input.accept.split(','),
        maxFileSize: 25 * 1024 * 1024,
        maxNumberOfFiles: 1,
      },
    });

    uploader.on('upload-progress', (_uploadedFile, progress) => {
      const percent = progress.bytesTotal ? Math.round(progress.bytesUploaded / progress.bytesTotal * 100) : 0;
      status.textContent = `Uploading ${file.name}: ${percent}%`;
    });

    uploader.on('upload-error', (_uploadedFile, error) => {
      status.textContent = `Upload failed: ${error.message}`;
      input.disabled = false;
      input.value = '';
    });

    uploader.on('upload-success', async (uploadedFile, response) => {
      const key = window.directUploadObjectKey(response);
      status.textContent = 'Upload complete; verifying and removing the temporary object…';

      try {
        const verification = await fetch('/account/upload-smoke-test/verify', {
          method: 'POST',
          credentials: 'same-origin',
          headers: {
            Accept: 'application/json',
            'Content-Type': 'application/json',
            'X-CSRF-Token': csrfToken(),
          },
          body: JSON.stringify({
            key,
            size: uploadedFile.size,
            authorization: window.directUploadAuthorization(key),
          }),
        });
        const result = await verification.json();
        if (!verification.ok) throw new Error(result.error || `verification returned ${verification.status}`);

        status.textContent = `Success: uploaded and verified ${uploadedFile.size} bytes, then removed the temporary object.`;
      } catch (error) {
        status.textContent = `Upload completed, but verification or cleanup failed: ${error.message}`;
      } finally {
        input.disabled = false;
        input.value = '';
      }
    });

    uploader.addFile({ name: file.name, type: file.type, data: file });
  });
};

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeUploadSmokeTest);
} else {
  initializeUploadSmokeTest();
}
