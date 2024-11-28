export const saveFile = async (blob: Blob, fileName: string) => {
  const blobUrl = URL.createObjectURL(blob);

  const anchor = document.createElement('a');
  anchor.href = blobUrl;
  anchor.download = fileName;
  anchor.style.display = 'none';
  document.body.append(anchor);

  anchor.click();

  setTimeout(() => {
    URL.revokeObjectURL(blobUrl);
    anchor.remove();
  }, 1_000);
};

export const base64ToBlob = (base64: string, type: string): Blob => {
  const byteString = atob(base64);
  const byteArray = new Uint8Array(byteString.length);
  for (let i = 0; i < byteString.length; i++) {
    byteArray[i] = byteString.charCodeAt(i);
  }

  return new Blob([byteArray], { type });
};
