function [df, dVals, emptyVals] = difField(varargin)
% [df, dVals, emptyVals] = difField(s1, s2, ...) return structure different
% field values and its fieldnames. The function also work for objects.
%
% Input:
%   s1, s2, ... - structures or objects to compare | struct (object) or
%                 cell-array of struct (object)
%
% Output:
%   df        - different fields among tested structures | cell-array of 
%               char
%   dVals     - different values in df | cell-array
%   emptyVals - empty values marker in df | logical
%
% Note:
%   Empty cells are ignored, empty structures are not.

  if nargout > 0
    df = {};
    dVals = {};
  end
  
  if nargin < 1
    help difField
    return
  end

  % put structrures and cell-arrays of structures to one cell-array
  structId = cellfun(@(x) isstruct(x) || isobject(x), varargin);
  cellId = cellfun(@iscell, varargin);
  assert(all(structId | cellId), ...
         'usefun:difField:wrongInput', ...
         'Input is not cell-array or structure')
  
  if any(cellId)
    strCell = [varargin{cellId}];
    assert(all(cellfun(@(x) isstruct(x) || isobject(x), strCell(:))), ...
           'usefun:difField:notStructCell', ...
           'There is a cell-array not containing a structure')
  else
    strCell = {};
  end
  strCell = [strCell(:), {varargin{structId}}];
  
  % one structure case is not comparable
  nStruct = length(strCell);
  if nStruct < 2
    df = {};
    return
  end
  
  % gain all subfields
  allSubfields = cellfun(@(x) subfields(x)', strCell, 'UniformOutput', false);
  uniqueSubfields = unique([allSubfields{:}]');
  nSubfields = length(uniqueSubfields);
  
  % gain field values
  subVal = cell(nSubfields, nStruct);
  emptyValues = false(nSubfields, nStruct);
  for s = 1:nStruct
    for f = 1:nSubfields
      try
        subVal{f, s} = eval(['strCell{s}.', uniqueSubfields{f}]);
        % if the field does not exist in the structure the following
        % command will not be performed
        emptyValues(f, s) = isempty(subVal{f, s});
      catch
      end
    end
  end
  
  % gain different fields and its values
  diffID = arrayfun(@(x) ~isequaln(subVal{x,:}), 1:nSubfields);
  % checkout empty fields
  diffID = diffID | arrayfun(@(x) any(emptyValues(x,:)) & ~all(emptyValues(x,:)), 1:nSubfields);
  % checkout NaN values because isequal returns O when values are NaN
  df = uniqueSubfields(diffID);
  dVals = subVal(diffID, :);
  emptyVals = emptyValues(diffID, :);
end