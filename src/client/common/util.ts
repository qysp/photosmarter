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
