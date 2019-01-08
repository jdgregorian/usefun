function coor = ind2coor(ind, matSize)
% coor = ind2coor(ind, matSize) transforms linear index of N-dimensional
% matrix of size matSize to MxN matrix of coordinates (subscripts).
%
% Input:
%   ind     - linear index | Mx1 or 1xM double vector
%   matSize - matrix size | 1xN vector
%
% Output:
%   coor - subscript/coordinate vector | MxN double
%
% See Also:
%   coor2ind, ind2sub, ind2vec

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
    coordChar = [coordChar, 'coor(:, ', num2str(d), '), '];
  end
  coordChar = [coordChar, 'coor(:, ', num2str(dim), ')'];
  eval(['[', coordChar, '] = ind2sub(matSize, ind);'])
  
end