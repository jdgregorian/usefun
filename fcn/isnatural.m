function res = isnatural(X, N, Z)
%ISNATURAL  True for natural numbers.
%   ISNATURAL(X) returns an array that contains 1's where
%   the elements of X are natural numbers and 0's where they are not.
%
%   ISNATURAL(X, N) returns an array that contains 1's where
%   the elements of X are natural numbers in range [1, N] and 0's 
%   otherwise.
%
%   ISNATURAL(X, N, 0) returns an array that contains 1's where
%   the elements of X are whole numbers in range [0, N] and 0's otherwise.
%
%   Input:
%     X - numeric array
%     N - number defining the maximal considered natural number
%     Z - 0 indicates range [0, N], other values [1, N]
%
%   Output:
%     R - logical array of size(X)
%
%   Example:
%     ISNATURAL([-1 0 1+2i; 2.2 3 8; pi NaN -Inf])    
%               [ 0 0  0  ;  0  1 1;  0  0    0 ]
%
%     ISNATURAL([-1 0 1+2i; 2.2 3 8; pi NaN -Inf], 4)    
%               [ 0 0  0  ;  0  1 0;  0  0    0 ]
%
%     ISNATURAL([-1 0 1+2i; 2.2 3 8; pi NaN -Inf], 4, 0)    
%               [ 0 1  0  ;  0  1 0;  0  0    0 ]
%
%   See also ISWHOLE, ISREAL, ISFINITE, ISINF.

  assert(nargin > 0, 'usefun:isnatural:nEnoughInput', 'Not enough input arguments.')
  if nargin < 3
    if nargin < 2
      N = Inf;
    end
    Z = 1;
  end
  % input check
  assert(N > 0, 'usefun:isnatural:boundNatural', 'N must be natural.')
  assert(isnumeric(Z), 'usefun:isnatural:zeroNum', 'Z must be numeric.')
  
  if Z == 0
    res = iswhole(X) & X > -1 & X < N;
  else
    res = iswhole(X) & X > 0  & X < N;
  end

end

