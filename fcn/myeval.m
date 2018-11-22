function res = myeval(s)
% res = myeval(s) evaluates expression in s if s is char or returns s
%
% Input:
%   s - expression to be evaluated or anything else
%
% Output:
%   res - result of evaluated expression
%
% See Also:
%   eval, evalin
  
  if nargin < 1
    if nargout > 0
      res = [];
    end
    help myeval
    return
  end
  
  if ischar(s)
    res = evalin('caller', s);
  else
    res = s;
  end
end