function ind = coor2ind(coor, matSize)
% ind = coor2ind(coor, matSize) transforms MxN vector of coordinates 
% (subscripts) of N-dimensional matrix of size matSize to linear index.
%
% Input:
%   coor - subscript/coordinate vector | MxN double matrix
%   matSize - matrix size | 1xN vector
%
% Output:
%   ind     - linear index | Mx1 double vector
%
% See Also:
%   ind2coor, sub2ind, vec2ind

  if nargin < 2
    if nargout > 0
      ind = [];
    end
    help coor2ind
    return
  end
  
  cellCoor = num2cell(coor);
  ind = zeros(size(coor, 1), 1);
  for i = 1:size(coor, 1)
    ind(i) = sub2ind(matSize, cellCoor{i, :});
  end
end