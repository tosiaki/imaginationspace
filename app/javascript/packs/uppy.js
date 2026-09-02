import Uppy from '@uppy/core';
import AwsS3 from '@uppy/aws-s3';

const csrfToken = () => {
  const token = document.querySelector('meta[name="csrf-token"]')?.content;
  if (!token) throw new Error('Unable to authorize upload (missing CSRF token)');
  return token;
};

const extensionFor = filename => {
  const match = filename.toLowerCase().match(/\.([a-z0-9]{1,10})$/);
  return match ? `.${match[1]}` : '';
};

const authorizeRequest = async (request, size) => {
  const response = await fetch('/s3/params', {
    method: 'POST',
    credentials: 'same-origin',
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken()
    },
    body: JSON.stringify({ ...request, size }),
  });

  if (!response.ok) {
    throw new Error(`Unable to authorize upload (${response.status})`);
  }

  return response.json();
};

window.createDirectUploader = options => {
  const uppy = new Uppy(options);
  const uploadSizes = new Map();

  uppy.use(AwsS3, {
    shouldUseMultipart: false,
    generateObjectKey: file => {
      const key = `${crypto.randomUUID()}${extensionFor(file.name)}`;
      uploadSizes.set(key, file.size);
      return key;
    },
    signRequest: request => authorizeRequest(request, uploadSizes.get(request.key))
  });

  return uppy;
};

window.directUploadObjectKey = uploadResponse => uploadResponse.body.key;
