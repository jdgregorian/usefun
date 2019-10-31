function str = printStructure(structure, varargin)
% printStructure(structure, FID) prints all fields and values of 
% 'structure' to file 'FID'. 
%
% printStructure(structure, FID, settings) prints 'structure' to file 'FID'
% with additional settings.
%
% printStructure(structure, settings) prints 'structure' to screen.
%
% Input:
%   structure - structure to print
%   FID       - file identifier or filename | integer or string
%   settings  - pairs of property (string) and value or struct with 
%               properties as fields:
%                 'StructName' - name of structure to be printed in result
%                 'Format'     - format of resulting string:
%                                  'value'  - returns only field values
%                                  'field'  - does not return structure 
%                                             name
%
% Output:
%   str - resulting string
%
% Notes:
%   - Printed structures and its fields can have size 2 at maximum. The
%     remaining dimensions will not be printed.
%   - Table is printed without Properties. Only VariableNames and RowNames
%     are included.
%   - Objects (or instances of any class having printable fields by 
%     fieldnames function) are printed in format: ClassName('Property1', 
%     Value1, 'Property2', Value2, ...). Such command (created using this 
%     function) probably will not be functional.

% TODO:
%   - increase dimension of printed structures and its values (printArray)
%   - additional properties of table
%   - categorical data

  str = [];
  if nargin < 2 || ~isnumeric(varargin{1})
    FID = 1;
    if nargin < 1
      help printStructure
      return
    end
  elseif isnumeric(varargin{1})
    FID = varargin{1};
    varargin = varargin(2:end);
  end
  
  % parse settings
  settings = settings2struct(varargin);
  structureName = defopts(settings, 'StructName', inputname(1));
  if isempty(structureName)
    structureName = 'structure';
  end
  option = defopts(settings, 'Format', '');
  
  % create higher structure for structure array handling (due to function
  % subfields
  extraStruct.s = structure;
  % gain all structure subfields
  settingsSF = subfields(extraStruct);
  % find main dot position
  dotPos = strfind(settingsSF{1}, '.');
  if ~isempty(dotPos)
    dotPos = dotPos(1);
  end
    
  % print all subfields
  for sf = 1:length(settingsSF)
    switch option
      case {'value', 'values'}
        strToPrint = '';
      case {'field', 'fields'}
        strToPrint = [settingsSF{sf}(dotPos+1:end), ' = '];
      otherwise
        if strcmp(structureName(end), ' ') || ~isstruct(structure)
          strToPrint = [structureName, settingsSF{sf}(3:end), ' = '];
        else
          strToPrint = [structureName, settingsSF{sf}(2:end), ' = '];
        end
    end
    str = prt(str, '%s', strToPrint);
    % eval due to multiple subfields
    valueSF = eval(['extraStruct.', settingsSF{sf}]);
    % array settings
    if numel(valueSF) > 1 && ~ischar(valueSF) && ~istable(valueSF)
      str = printArray(str, valueSF);
    % non-array value
    else
      str = printVal(str, valueSF);
     end
    if strcmp(option, 'value')
      if length(settingsSF) ~= 1
        str = prt(str, '\n');
      end
    else
      str = prt(str, ';\n');
    end

  end
  
  if nargout < 1
    recentlyOpened = false;
    if ischar(FID)
      % printing results to txt file
      resultname = FID;
      FID = fopen(resultname, 'w');
      assert(FID ~= -1, 'Cannot open %s !', resultname)
      recentlyOpened = true;
    end

    % print to file
      fprintf(FID, '%s', str);
      clear str

    % close opened file
    if recentlyOpened
      fclose(FID);
    end
  end
  
end

function str = prt(str, varargin)
% adds string to str
  str = [str, sprintf(varargin{:})];
end

function str = printVal(str, val)
% function checks the class of value and prints it in appropriate format

  % empty set
  if isempty(val)
    str = printEmpty(str, val);
  % cell or any kind of array (except char and table)
  elseif iscell(val) || (numel(val) > 1 && ~ischar(val) && ~istable(val))
    str = printArray(str, val);
  % rest of classes
  else
    switch class(val)
      case 'char'
        str = printChar(str, val);
      case 'double'
        % complex numbers
        ival = imag(val);
        if ival ~= 0
          str = printVal(str, real(val));
          if isnan(ival)
            str = prt(str, '+NaN*1i');
          else
            if ival > 0
              str = prt(str, '+');
            end
            str = printVal(str, ival);
            str = prt(str, 'i');
          end
        % NaN and Inf verification is part of condition because they cannot 
        % be converted to logicals
        elseif (isnan(val) || abs(val) == Inf || (mod(val,1) && abs(val) > 1))
          str = prt(str, '%f', val);
        elseif mod(val,1)
          str = prt(str, '%g', val);
        else
          str = prt(str, '%d', val);
        end
      case 'logical'
        if val
          str = prt(str, 'true');
        else
          str = prt(str, 'false');
        end
      case 'function_handle'
        str = prt(str, '@%s', func2str(val));
      case 'struct'
        str = printStruct(str, val);
      case 'table'
        str = printTable(str, val);
      otherwise
        % try other numerical types
        if isnumeric(val)
          str = prt(str, '%s(', class(val));
          str = printVal(str, double(val));
          str = prt(str, ')');
        else
          % try if the class has printable fields  
          try
            warning('off', 'MATLAB:structOnObject')
            str = printStruct(str, struct(val), class(val));
            warning('on', 'MATLAB:structOnObject')
          catch
            str = prt(str, '%dx%d %s', size(val,1), size(val,2), class(val));
          end
        end
    end
  end
end

function str = printArray(str, val)
% function prints array

  % warn if the val dimension is greater than 2
  if ~ismatrix(val)
    warning('usefun:printStructure:largedim', ...
      ['Variable contains array with dimension greater than 2 (%d). ', ...
       'Only the first two dimensions will be printed.'], ndims(val))
  end

  % cell array
  if iscell(val)
    str = prt(str, '{');
    % first row
    str = printVal(str, val{1,1});
    for c = 2:size(val,2)
      str = prt(str, ', ');
      str = printVal(str, val{1,c});
    end
    % rest of rows
    for r = 2:size(val,1)
      str = prt(str, '; ');
      str = printVal(str, val{r,1});
      for c = 2:size(val,2)
        str = prt(str, ', ');
        str = printVal(str, val{r,c});
      end
    end
    str = prt(str, '}');
  % other arrays
  else
    str = prt(str, '[');
    % first row
    str = printVal(str, val(1,1));
    for c = 2:size(val,2)
      str = prt(str, ', ');
      str = printVal(str, val(1,c));
    end
    % rest of rows
    for r = 2:size(val,1)
      str = prt(str, '; ');
      str = printVal(str, val(r,1));
      for c = 2:size(val,2)
        str = prt(str, ', ');
        str = printVal(str, val(r,c));
      end
    end
    str = prt(str, ']');
  end
end

function str = printStruct(str, s, structName)
% prints structure s or unknown type structName

  if nargin < 3
    structName = 'struct';
  end
  sf = fieldnames(s);
  str = prt(str, '%s(', structName);
  if ~isempty(sf)
    str = prt(str, '''%s'', ', sf{1});
    str = printVal(str, s.(sf{1}));
    for fnum = 2 : length(sf)
      str = prt(str, ', ''%s'', ', sf{fnum});
      str = printVal(str, s.(sf{fnum}));
    end
  end
  str = prt(str, ')');
end

function str = printChar(str, val)
% prints char values row by row

  if size(val, 1) > 1
    str = prt(str, '[');
    % first row
    str = prt(str, '''%s''', val(1, :));
    % rest of rows
    for r = 2:size(val,1)
      str = prt(str, '; ');
      str = prt(str, '''%s''', val(r, :));
    end
    str = prt(str, ']');
  else
    str = prt(str, '''%s''', val);
  end
end

function str = printTable(str, tab)
% prints table tab
  varNames = tab.Properties.VariableNames;
  str = prt(str, 'table(');
  if ~isempty(tab)
    % all columns
    for v = 1:numel(varNames)
      str = printVal(str, tab.(varNames{v}));
      str = prt(str, ', ');
    end
    % variable names
    str = prt(str, '''VariableNames'', ');
    str = printVal(str, tab.Properties.VariableNames);
    % row names
    str = prt(str, ', ''RowNames'', ');
    str = printVal(str, tab.Properties.RowNames);
  end
  str = prt(str, ')');
end

function str = printEmpty(str, val)
% print empty value
  switch class(val)
    case 'cell'
      str = prt(str, '{}');
    case 'char'
      str = prt(str, '''''');
    case 'table'
      str = prt(str, 'table()');
    otherwise
      str = prt(str, '[]');
  end
end