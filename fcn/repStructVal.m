function s = repStructVal(s, origVal, newVal, mode)
% s = repStructVal(s, origVal, newVal) replace values origVal in structure
% fields by newVal value.
%
% s = repStructVal(s, condition, newVal, 'test') replace values in 
% structure fields satisfying condition by newVal value.
%
% Input:
%   s         - original structure | struct
%   origVal   - values to be replaced
%   condition - condition on values to be tested | handle returning logical
%   newVal    - new value replacing origVal
%   mode      - compare values or test condition | {'values', 'test'}
%             - 'values' is default - important for comparing handles
%
% Output:
%   s - structure with replaced origVals by newVal
%
% Notes:
%   1) Comparison of values is performed before structure search.
%      On the contrary, condition testing is performed after structure
%      search.
%   2) If condition testing throws an error, the condition is considered as 
%      not satisfied.
%
% See Also:
%   difField

  if nargin < 4
    if nargin < 1
      if nargout > 0
        s = [];
      end
      help repStructVal
      return
    end
    mode = 'values';
  end
  
  if strcmp(mode, 'values')
    s = repStructValEqual(s, origVal, newVal);
  % test if function returns logical
  elseif isa(origVal, 'function_handle') && islogical(origVal([]))
    s = repStructValTest(s, origVal, newVal);
  else
    error('In non-value mode only handles returning logicals are accepted as conditions')
  end
  
end

function s = repStructValEqual(s, origVal, newVal)
% replace structure value by new value

  fn = fieldnames(s);
  for f = 1:numel(fn)
    if isequaln(s.(fn{f}), origVal)
      s.(fn{f}) = newVal;
    elseif isstruct(s.(fn{f}))
      s.(fn{f}) = repStructValEqual(s.(fn{f}), origVal, newVal);
    end
  end
end

function s = repStructValTest(s, condition, newVal)
% replace structure value if it satisfies specified condition

  fn = fieldnames(s);
  for f = 1:numel(fn)
    try
      if isstruct(s.(fn{f}))
        s.(fn{f}) = repStructValTest(s.(fn{f}), condition, newVal);
      elseif condition(s.(fn{f}))
        s.(fn{f}) = newVal;
      end
    catch
      % condition is considered as not satisfied
    end
  end
end