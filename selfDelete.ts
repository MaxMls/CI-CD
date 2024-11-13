import fs from 'fs';

// Get the path of the current script
const currentFile = import.meta.url.slice(7); // This gets the file path from the module URL

// Delete the script file
fs.unlink(currentFile, (err) => {
  if (err) {
    console.error('Error deleting file:', err);
    return;
  }
  console.log('File deleted successfully');
});
