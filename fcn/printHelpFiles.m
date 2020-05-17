function printHelpFiles(filename, directory)
% printHelpFiles(filename, directory) prints all help files in defined 
% 'directory' and its subdirectories to TeX file 'filename'.

% TODO: Add different source code formats (.sh, etc.)

  if nargin < 2
    if nargin < 1
      texFolder = fullfile('doc', 'tex');
      filename = fullfile(texFolder, 'function_help.tex');
      if ~isdir(texFolder)
        mkdir(texFolder)
      end
    end
    directory = '.';
  end

  % find files in directory
  allNames = searchFile(directory, '*.m');
  
  % open file
  FID = fopen(filename, 'w');
  
  % print all helps
  for f = 1:length(allNames)
    [~, funcName] = fileparts(allNames{f});
    fprintf(FID, '\\functionhelp{%s}', funcName);
    fprintf(FID, '{%s}\n\n', help(funcName));
  end

  % close file
  fclose(FID);

end
