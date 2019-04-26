function res = iswhole(X)
%ISWHOLE  True for whole numbers.
%   ISWHOLE(X) returns an array that contains 1's where
%   the elements of X are whole numbers and 0's where they are not.
%
%   Example:
%     ISWHOLE([1+2i 2.2 3 pi NaN -Inf]) is [0 0 1 0 0 0].
%
%   See also ISNATURAL, ISREAL, ISFINITE, ISINF.

  assert(nargin > 0, 'usefun:iswhole:nEnoughInput', 'Not enough input arguments.')
  if isnumeric(X)
    res = (imag(X) == 0);
    res(res) = (mod(X(res), 1) == 0);
  elseif ischar(X)
    res = false(size(X));
  else
    error('usefun:iswhole:undefined', ...
      'Undefined function ''iswhole'' for input type ''%s''.', ...
      class(X))
  end

end

