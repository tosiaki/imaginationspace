import Uppy from '@uppy/core';
import AwsS3 from '@uppy/aws-s3';

const getPresignedPost = async (file, signal) => {
  const location = new URL('/s3/params', window.location.origin);
  location.search = new URLSearchParams({
    filename: file.name,
    type: file.type || 'application/octet-stream'
  });

  const response = await fetch(location, {
    credentials: 'same-origin',
    headers: { Accept: 'application/json' },
    signal
  });

  if (!response.ok) {
    throw new Error(`Unable to authorize upload (${response.status})`);
  }

  const parameters = await response.json();
  return {
    ...parameters,
    method: parameters.method.toUpperCase()
  };
};

window.createDirectUploader = options => {
  const uppy = new Uppy(options);

  uppy.use(AwsS3, {
    shouldUseMultipart: false,
    getUploadParameters: async (file, { signal }) => {
      const parameters = await getPresignedPost(file, signal);
      uppy.setFileMeta(file.id, { key: parameters.fields.key });
      return parameters;
    }
  });

  return uppy;
};
