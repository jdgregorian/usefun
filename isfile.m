function res = isfile(filename)
%ISFILE  True if argument is a file.
%   ISFILE(FILENAME) returns a 1 if FILENAME is a file and 0 otherwise.
%
%   See also FINFO, ISDIR.

  res = logical(exist(filename, 'file')) && ~isdir(filename);
end