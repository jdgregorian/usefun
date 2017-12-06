function s = safermfield(s, fields)
% SAFERMFIELD Safely remove fields from a structure array.
%   S = SAFERMFIELD(S, 'field') removes the specified field from the
%   m x n structure array S. The size of input S is preserved.
%   If the specified field does not exist, the S is returned unchanged.
% 
%   S = SAFERMFIELD(S, FIELDS) removes more than one field at a time
%   when FIELDS is a character array or cell array of strings.  The
%   changed structure is returned. The size of input S is preserved.
%   Only the fields from FIELDS which do exist are removed.
% 
%   See Also: 
%     rmfield, isfield, setfield, getfield, fieldnames

  if nargin < 2
    help safermfield
    return
  end
    
  if ischar(fields)
    fields = {fields};
  end
  
  % find existing fields
  existingFields = isfield(s, fields);
  % remove existing fields
  if any(existingFields)
    s = rmfield(s, fields(existingFields));
  end
  
end