function A = catstruct(varargin)
% CATSTRUCT   Concatenate or merge structures with different fieldnames
%   X = CATSTRUCT(S1,S2,S3,...) merges the structures S1, S2, S3 ...
%   into one new structure X. X contains all fields present in the various
%   structures. An example:
%
%     A.name = 'Me';
%     B.income = 99999;
%     X = catstruct(A,B) 
%     % -> X.name = 'Me';
%     %    X.income = 99999;
%
%   If a fieldname is not unique among structures (i.e., a fieldname is
%   present in more than one structure), only the value from the last
%   structure with this field is used. In this case, the fields are 
%   alphabetically sorted. A warning is issued as well. An axample:
%
%     S1.name = 'Me';
%     S2.age  = 20; 
%     S3.age  = 30; 
%     S4.age  = 40;
%     S5.honest = false;
%     Y = catstruct(S1, S2, S3, S4, S5) % use value from S4
%
%   The inputs can be array of structures. All structures should have the
%   same size. An example:
%
%     C(1).bb = 1; C(2).bb = 2;
%     D(1).aa = 3; D(2).aa = 4;
%     CD = catstruct(C, D) % CD is a 1x2 structure array with fields bb and 
%                          % aa
%
%   The last input can be the string 'sorted'. In this case,
%   CATSTRUCT(S1,S2, ..., 'sorted') will sort the fieldnames alphabetically. 
%   To sort the fieldnames of a structure A, you could use
%   CATSTRUCT(A,'sorted') but I recommend ORDERFIELDS for doing that.
%
%   When there is nothing to concatenate, the result will be an empty
%   struct (0x0 struct array with no fields).
%
%   Notes: 
%     1) To concatenate similar arrays of structs, you can use simple
%        concatenation: 
%          A = dir('*.mat'); B = dir('*.m'); C = [A; B];
%     2) This function relies on unique. Matlab changed the behavior of
%        its set functions since 2013a, so this might cause some backward
%        compatibility issues when duplicated fieldnames are found.
%
%   See also:
%     CAT, STRUCT, FIELDNAMES, STRUCT2CELL, ORDERFIELDS

% Original version (4.1, (c) Jos van der Geest, jos@jasen.nl) downloaded 
% from:
% https://www.mathworks.com/matlabcentral/fileexchange/7842-catstruct

  narginchk(1, Inf);
  N = nargin;

  if ~isstruct(varargin{end})
    if isequal(varargin{end}, 'sorted')
      narginchk(2, Inf);
      sorted = 1;
      N = N - 1;
    else
      error('catstruct:InvalidArgument', ...
        'Last argument should be a structure, or the string "sorted".');
    end
  else
    sorted = 0;
  end
  
  sz0 = []; % used to check that all inputs have the same size
  
  % used to check for a few trivial cases
  nonEmptyInputs = false(N, 1); 
  nonEmptyInputsN = 0;
  
  % used to collect the fieldnames and the inputs
  fn = cell(N, 1);
  val = cell(N, 1);
  
  % parse the inputs
  for ii = 1 : N
    X = varargin{ii};

    if ~isempty(X)
      if ~isstruct(X)
        error('catstruct:InvalidArgument', ...
          ['Argument #' num2str(ii) ' is not a structure.']);
      end
      
      % empty structs are ignored
      if ii > 1 && ~isempty(sz0)
        if ~isequal(size(X), sz0)
          error('catstruct:UnequalSizes', ...
            'All structures should have the same size.');
        end
      else
        sz0 = size(X);
      end
      nonEmptyInputsN = nonEmptyInputsN + 1;
      nonEmptyInputs(ii) = true;
      fn{ii} = fieldnames(X);
      val{ii} = struct2cell(X);
    end
  end
  
  if nonEmptyInputsN == 0
    % all structures were empty
    A = struct([]);
  elseif nonEmptyInputsN == 1
    % there was only one non-empty structure
    A = varargin{nonEmptyInputs};
    if sorted
      A = orderfields(A);
    end
  else
    % there is actually something to concatenate
    fn = cat(1, fn{:});
    val = cat(1, val{:});
    fn = squeeze(fn);
    val = squeeze(val);

    [ufn, ind] = unique(fn, 'last');
    % If this line errors, due to your matlab version not having UNIQUE
    % accept the 'last' input, use the following line instead
    % [ufn, ind] = unique(fn); % earlier ML versions, like 6.5

    if numel(ufn) ~= numel(fn)
      warning('catstruct:DuplicatesFound', ...
        'Fieldnames are not unique between structures.');
      sorted = 1;
    end

    if sorted
      val = val(ind, :);
      fn = fn(ind, :);
    end

    A = cell2struct(val, fn);
    A = reshape(A, sz0); % reshape into original format
  end
  
end