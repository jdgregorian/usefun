function coor = ind2coor(ind, matSize)
% coor = ind2coor(ind) transforms linear index of N-dimensional
% matrix of size matSize to 1xN vector of coordinates (subscripts).
%
% Input:
%   ind     - linear index | 1x1 double
%   matSize - matrix size | 1xN vector
%
% Output:
%   coor - subscript/coordinate vector | 1xN double vector
%
% See Also:
%   ind2sub, ind2vec

  if nargin < 2
    if nargout > 0
      coor = [];
    end
    help ind2coor
    return
  end
  
  dim = numel(matSize);
  coordChar = [];
  for d = 1 : dim - 1
    coordChar = [coordChar, 'coor(', num2str(d), '), '];
  end
  coordChar = [coordChar, 'coor(', num2str(dim), ')'];
  eval(['[', coordChar, '] = ind2sub(matSize, ind);'])
  
end