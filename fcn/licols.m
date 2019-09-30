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
  
  Xsub = [];
  idx = [];
  
  if nargin < 2
    if nargin < 1
      help licols
      if nargout < 1
        clear Xsub
      end
      return
    end
    tol = eps;
  end

  % transform table input into array
  if istable(X)
    Xtab = X;
    X = table2array(X);
  end
  
  % check input
  assert(isnumeric(tol) && numel(tol) == 1 && tol > 0, ...
    'usefun:licols:positiveTol', 'Tolerance has to be scalar greater than zero')
  assert(isnumeric(X), 'usefun:licols:numInput', 'Input matrix has to be numerical')

  % exclude columns containing NaN and Inf values
  isNaNInf = any(isnan(X) | isinf(X), 1);

  % X has no non-zeros and hence no independent columns
  if ~nnz(X(:, ~isNaNInf))
    idx = find(isNaNInf);

  % if there is only one column remaining
  elseif ( size(X(:, ~isNaNInf), 2) == 1 )
    idx = 1:size(X, 2);

  % otherwise
  else
    % QR decomposition
    [~, R, E] = qr(X(:, ~isNaNInf), 0);

    if ~isvector(R)
      diagr = abs(diag(R));
    else
      diagr = R(1);
    end

    % rank estimation
    r = find(diagr >= tol*diagr(1), 1, 'last');

    idx = sort([E(1:r), find(isNaNInf)]);
  end

  % table case
  if exist('Xtab', 'var')
    Xsub = Xtab(:, idx);
  % array case
  else
    Xsub = X(:, idx);
  end
   
end