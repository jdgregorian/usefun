function fileList = searchFile(folder, name)
% fileList = searchFile(folder, name) finds files 'name' in 'folder' and 
% its subfolders.
%
% fileList = searchFile(name) finds files 'name' in current folder and its 
% subfolders.
%
% Input:
%   folder - folder for search | string
%   name   - pattern to search | string
%
% Output:
%   fileList - files found in folder | cell-array of strings
%
% See Also:
%   dir

  if nargin < 1
    name = '*';
    folder = '.';
  end
  if nargin == 1
    name = folder;
    folder = '.';
  end

  fileList = listFolder(folder, name);

end

function fileList = listFolder(folder, pattern)
% recursive function searching 'pattern' in 'folder'

  % find directories in folder
  % fprintf('%s\n', folder)
  folderList = dir(folder);
  % exclude '.' and '..' from folderList
  folderList = removePositionFolders(folderList);
  % locate directories
  directories = find([folderList.isdir]);
  % find files according to pattern
  fileList = dir(fullfile(folder, pattern));
  % exclude '.' and '..' from fileList
  fileList = removePositionFolders(fileList);
  fileList = cellfun(@(x) fullfile(folder, x), {fileList(:).name}, 'UniformOutput', false)';
  % search all subdirectories
  for f = 1:length(directories)
    fileList = [fileList; listFolder(fullfile(folder, folderList(directories(f)).name), pattern)];
  end
  
end

function list = removePositionFolders(list)
% remove . and .. from file list

  remId = strcmp({list.name}, '.');
  remId = remId | strcmp({list.name}, '..');
  list(remId) = [];

end