function [Xsub, idx] = licols(X, tol)
% Extract a linearly independent set of columns of a given matrix X.
%
%    [Xsub, idx] = licols(X, tol)
%
% Input:
%   X   - input matrix | MxN matrix
%   tol - rank estimation tolerance | (default = eps)
%
% Output:
%   Xsub - extracted columns of X | MxP matrix (P<=N)
%   idx  - indices (into X) of the extracted columns
%
% Note:
%   Columns containing NaN or Inf values are automatically considered as
%   linearly independent.
%
% See Also:
%   qr

% Implemented according to Matt J's answer to linear dependency in matrix.
% https://www.mathworks.com/matlabcentral/answers/108835-how-to-get-only-li
% nearly-independent-rows-in-a-matrix-or-to-remove-linear-dependency-b-w-ro
% ws-in-a-m#answer_117458
  
  if nargout > 1
    Xsub = [];
    idx = [];
  end
  
  if nargin < 2
    if nargin < 1
      help licols
      return
    end
    tol = eps;
  end

  % transform table input into array
  if istable(X)
    Xtab = X;
    X = table2array(X);
  end
  
  % X has no non-zeros and hence no independent columns
  if ~nnz(X)
    return
  end

  % exclude columns containing NaN and Inf values
  isNaNInf = any(isnan(X) | isinf(X));
  [~, R, E] = qr(X(:, ~isNaNInf), 0);

  if ~isvector(R)
    diagr = abs(diag(R));
  else
    diagr = R(1);
  end

  % rank estimation
  r = find(diagr >= tol*diagr(1), 1, 'last');

  idx = sort([E(1:r), find(isNaNInf)]);
  % table case
  if exist('Xtab', 'var')
    Xsub = Xtab(:, idx);
  % array case
  else
    Xsub = X(:, idx);
  end
   
end