classdef LatexTable < handle
% LatexTable Class generating a LaTeX table from a given MATLAB cellarray
%   or table.
%   LT = LatexTable(data, opts) builds an object for printing 'data' to
%   LaTeX table using options in 'opts'.
%
% Input:
%   data - data for table printing | table, cell-array, double
%   opts - options of table with the following fields:
%     'booktabs'             - use package booktabs | logical scalar |
%                              default: false
%                            - don't forget to include
%                              \usepackage{booktabs} in LaTex file when
%                              true
%     'dataFormat'           - format of data | cell-array of string
%     'dataNanString'        - string for NaN replacement | string |
%                              default: $-$
%     'midLines'             - specify numbers of table rows after which
%                              middle lines should be used | integer vector
%                              | default: 1 - after the header
%     'tableBorders'         - use table borders | logical scalar |
%                              default: false
%     'tableCaption'         - LaTeX table caption | string | default: ''
%     'tableColumnAlignment' - column alignment in Latex table ('l' =
%                              left-justified, 'c' = centered, 'r' =
%                              right-justified) | string or cell-array of
%                              strings
%     'tableLabel'           - LaTex table label | string | default: ''
%
% LatexTable methods:
%   getNRows - get number of data rows
%   getNCols - get number of data columns
%   setHeaderRow - set header-row of the table
%   setHeaderCol - set header-column of the table
%   setColumnFormat - specify the format for the columns
%   setFormatXY     - set the format for the data value in x-th row and y-th column
%   prependFormatXY - prepend the string to the format in the x-th row and y-th column
%   appendFormatXY  - append the string to the format in the x-th row and y-th column
%   colorizeSubMatrixInGray - turn part of table to gray background
%   colorizeRowsInGray      - turn specified rows to gray background
%   toStringTable - generate strings for final table
%   toStringRows - generate the final LaTeX code
%   toFile - print resulting table to TeX file
%
% LatexTable properties:
%   opts - table options
%   data - original data values
%   headerRow - LaTeX header row
%   headerCol - LaTeX header column
%   formats - formats for individual cells
%
% Formatting-string to set the precision of the table values:
%   For using different formats in different rows use a cell array like
%   {myFormatString1, numberOfValues1, myFormatString2, numberOfValues2, 
%   ... } where myFormatString_ are formatting-strings and numberOfValues_
%   are the number of table columns or rows that the preceding 
%   formatting-string applies. Please make sure the sum of numberOfValues_
%   matches the number of columns or rows in input.tableData.
%
% Option setting examples:
%   opts.dataFormat = {'%.4f'}; % uses three digit precision floating point
%                               % for all data values
%   opts.dataFormat = {'%.3f',2,'%.1f',1}; % three digits precision for
%                                          % first two columns, one digit
%                                          % for the last
%   opts.dataNanString = '$-$';
%   opts.tableColumnAlignment = 'c';
%   % OR
%   opts.tableColumnAlignment = {'c', 'l', 'r', 'c'};
%   opts.tableBorders = 1;
%   opts.booktabs = 1;
%   opts.tableCaption = 'MyTableCaption';
%   opts.tableLabel = 'MyTableLabel';
%
% Example:
%
%   header = {'covf', 'meanf', 'ell', 'D2', 'D3', 'D5', 'D10', 'D20', 'average'};
%   data   = [covCol, meanCol, ellCol, num2cell(rdePerDim), meanRDECol];
% 
%   fixedHypersTable = cell2table(data, 'VariableNames', header);
%   writetable(fixedHypersTable, '../latex/paper/data/fixedHypers.csv');
% 
%   lt = LatexTable(fixedHypersTable);
%   lt.headerRow = {'covariance f.', '$m_\mu$', '$\ell$', '$2D$', '$3D$', '$5D$', '$10D$', '$20D$', '\textbf{average}'}';
%   lt.opts.tableColumnAlignment = num2cell('lcccccccc');
%   lt.opts.numericFormat = '$%.2f$';  % set up the default format for numerics
%   lt.opts.booktabs = 1;     % use nice-looking tables
%   lt.opts.latexHeader = 0;  % do not print the header like '\begin{table}...
%   % identify minimas and set them bold
%   [~, minRows] = min([rdePerDim, meanRDE]);
%   for j = 1:size([rdePerDim, meanRDE], 2)
%     lt.setFormatXY(minRows(j), 3+j, '$\\bf %.2f$');
%   end
%   latexRows = lt.toStringRows(lt.toStringTable);
%   % delete the lines \begin{tabular}{...} \toprule
%   % and              \bottomrule  \end{tabular}
%   latexRows([1,2,end-1,end]) = [];
%   % save the result in the file
%   fid = fopen('../latex_scmaes/ec2016paper/data/fixedHypers.tex', 'w');
%   for i = 1:length(latexRows)
%     fprintf(fid, '%s\n', latexRows{i});
%   end
%   fclose(fid);
%
% Latex packages to include (\usepackage{...})
%   booktabs - modern looking tables
%   colortbl - coloring of table background

% Authors:       Lukas Bajer and Zbynek Pitra
% Original author:  Eli Duenisch
% Date:         July 31, 2017
% License:      This code is licensed using BSD 2 to maximize your freedom of using it :)
%
% original copyright:
% ----------------------------------------------------------------------------------
%  Copyright (c) 2016, Eli Duenisch
%  All rights reserved.
%  
%  Redistribution and use in source and binary forms, with or without
%  modification, are permitted provided that the following conditions are met:
%  
%  * Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
%  
%  * Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
%  
%  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
%  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
%  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
%  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
%  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
% ----------------------------------------------------------------------------------

  properties
    % opts - Table options
    opts
    data
    headerRow
    headerCol
    formats
  end
  
  methods
    function this = LatexTable(data, opts)
      %%%%%%%%%%%%%%%%%%%%%%%%%% Default settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % These settings are used if the corresponding optional inputs are not given.
      %
      % Placement of the table in LaTex document
      if (~exist('opts', 'var') || ~isstruct(opts))
        fprintf('Options are not specified...\n');
        opts = struct();
      end

      if (isfield(opts,'tablePlacement') && ~isempty(opts.tablePlacement))
        opts.tablePlacement = ['[', opts.tablePlacement, ']'];
      else
        opts.tablePlacement = '';
      end

      this.opts = opts;

      % Pivoting of the input data switched off per default:
      % Sets the default display format of numeric values in the LaTeX table to '%.4f'
      % (4 digits floating point precision).
      if ~isfield(opts,'numericFormat'), this.opts.numericFormat = '%.4f'; end
      % Define what should happen with NaN values in opts.tableData:
      if ~isfield(opts,'dataNanString'), this.opts.dataNanString = '$-$'; end
      % Specify the alignment of the columns:
      % 'l' for left-justified, 'c' for centered, 'r' for right-justified
      if ~isfield(opts,'tableColumnAlignment'), this.opts.tableColumnAlignment = 'c'; end
      % Print also LaTeX header like '\begin{table}...\caption{...}..\begin{table}
      if ~isfield(opts,'latexHeader'), this.opts.latexHeader = 1; end
      % Specify whether the table has borders:
      % 0 for no borders, 1 for borders
      if ~isfield(opts,'tableBorders'), this.opts.tableBorders = 0; end
      % Specify whether to use booktabs formatting or regular table formatting:
      if ~isfield(opts,'booktabs')
        this.opts.booktabs = 0;
      else
        if (opts.booktabs)
          this.opts.tableBorders = 0;
        end
      end
      % Specify if some middle lines should be used (default: 1 - after the
      % first line)
      if ~isfield(opts, 'midLines')
        this.opts.midLines = 1;
      end
      % Other optional fields:
      if ~isfield(opts,'tableCaption'), this.opts.tableCaption = ''; end
      if ~isfield(opts,'tableLabel'), this.opts.tableLabel = ''; end
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      this.headerRow = {};
      this.headerCol = {};

      % convert the input 'data' into cell array
      if isa(data, 'table')
        % table format
        if(~isempty(data.Properties.RowNames))
          this.headerCol = data.Properties.RowNames';
        end
        if(~isempty(data.Properties.VariableNames))
          if isempty(this.headerCol)
            this.headerRow = data.Properties.VariableNames';
          else
            this.headerRow = [{''}; data.Properties.VariableNames'];
          end
        end
        this.data = table2cell(data);
      elseif (isnumeric(data))
        % numerical matrix
        this.data = num2cell(data);
      elseif (iscell(data))
        % cell-array
        this.data = data;
      else
        error('Data has to be either table, cell array, or numeric matrix');
      end
      this.formats = cell(size(this.data));
      this.opts.grayLevelRow = [];
    end
    
    function n = getNRows(this)
      % get number of rows
      n = size(this.data, 1);
    end
    
    function n = getNCols(this)
      % get number of columns
      n = size(this.data, 2);
    end

    function setHeaderRow(this, header)
      % set the following nx1 cell array of strings as header-row of the
      % table
      this.headerRow = header;
    end
    
    function setHeaderCol(this, colHeader)
      % set the following rx1 cell array of strings as header-column of the
      % table
      this.headerCol = colHeader;
    end

    function setColumnFormat(this, colFormats)
      % specify the 'printf'-like format for the columns, or for all
      % columns
      if (ischar(colFormats))
        colFormats = {colFormats};
      elseif (~iscell(colFormats))
        error('Formats has to be in a cell array');
      end
      
      if (length(colFormats) == 1)
        colFormats = repmat(colFormats, this.getNRows(), this.getNCols());
      elseif (length(colFormats) ~= this.getNCols())
        error('The number of cells in colFormats does not agree with # cols of the data');
      end
      
      this.formats = repmat(colFormats, this.getNRows(), 1);
    end
    
    function setFormatXY(this, i, j, formatStr)
      % set the sprintf-like format for the coordinates x,y
      %
      % setFormatXY(formatStr) - sets specified format to all cells
      %
      % setFormatXY(X, formatStr) - sets specified format to cells marked
      %                             as true in logical matrix X
      %
      % setFormatXY(x, y, formatStr) - sets specified format to cell with
      %                                coordinates in row x and column y
      %
      % Input:
      %   formatStr - sprintf-like format | string
      %             - Note: remember some characters have special meanings
      %               in sprinf (e.g. \)
      %   X         - matrix identifying cells to format | logical matrix
      %   x         - row number of the format | integer scalar
      %   y         - column number of the format | integer scalar
      %
      % Example:
      %   a = LatexTable([1, 2; 3, 4]);
      %   % set \emph{%d} to row 1 column 2
      %   a.setFormatXY(1, 2, '\\emph{%d}');
      %   a.toStringTable
      %
      %   ans =
      %
      %     2x2 cell array
      %
      %       '1.0000'    '\emph{2}'
      %       '3.0000'    '4.0000'

      if nargin == 2 && ischar(i)
        % set format to all fields
        this.formats(:) = {i};
      elseif nargin == 3 && islogical(i) && ischar(j)
        % set format to fields specified in i
        this.formats(i) = {j};
      elseif nargin == 4 && isnatural(i) && isnatural(j) && ischar(formatStr)
        this.formats{i,j} = formatStr;
      else
        error('usefun:LatexTable:wrongFormatSet', 'Format has to be a string')
      end
    end
    
    function prependFormatXY(this, i, j, formatStr)
      % prepend the printf-like format at the coordinates x,y
      if (isempty(this.formats{i,j}))
        if (isnumeric(this.data{i,j}))
          this.formats{i,j} = this.opts.numericFormat;
        else
          this.formats{i,j} = '%s';
        end
      end
      this.formats{i,j} = [formatStr, ' ', this.formats{i,j}];
    end

    function appendFormatXY(this, i, j, formatStr)
      % append the printf-like format at the coordinates x,y
      if (isempty(this.formats{i,j}))
        if (isnumeric(this.data{i,j}))
          this.formats{i,j} = this.opts.numericFormat;
        else
          this.formats{i,j} = '%s';
        end
      end
      this.formats{i,j} = [this.formats{i,j}, ' ', formatStr];
    end
    
    function colorizeSubMatrixInGray(this, values, row, col, minGray, maxGray)
      % Colorize specified submatrix of the table to gray background.
      %
      % Input:
      %   values  - measure of gray level between 'minGray' and 'maxGray'
      %             for all submatrix elements  | double matrix
      %   row     - row number of first submatrix element in table |
      %             integer scalar
      %   col     - column number of first submatrix element in table |
      %             integer scalar
      %   minGray - lower bound of gray-scale | double scalar
      %   maxGray - upper bound of gray-scale | double scalar
      %
      % Note: Don't forget to include \usepackage{colortbl} in LaTex file.
      
      minValue = min( min( values ) );
      maxValue = max( max( values ) );
      for i = 1:size(values,1)
        for j = 1:size(values,2)
          if minValue == maxValue
            grayValue = (maxGray - minGray)/2 + minGray;
          else
            grayValue = ((values(i,j) - minValue) / (maxValue-minValue)) ...
                * (maxGray - minGray) + minGray;
          end
          if (grayValue < 1.0)
            this.prependFormatXY(row+i-1, col+j-1, ['\\cellcolor[gray]{' sprintf('%.4f', grayValue) '}']);
          end
        end
      end
    end
    
    function colorizeRowsInGray(this, rows, values, minGray, maxGray)
      % Colorize specified rows of the table to gray background
      %
      % Input:
      %   row     - ids of rows to colorize (1 is the first row under the
      %             header) | integer or logical vector
      %   values  - values taken as a measure of gray level between
      %             'minGray' and 'maxGray' | double matrix
      %   minGray - lower bound of gray-scale | double scalar
      %   maxGray - upper bound of gray-scale | double scalar
      %
      % Note: Don't forget to include \usepackage{colortbl} in LaTex file.
      
      if nargin < 5
        if nargin < 4
          if nargin < 3
            if nargin < 2
              % colorize all rows
              rows = size(this.data, 1);
            end
            % full gray
            if islogical(rows)
              values = ones(sum(rows), 1);
            else
              values = ones(numel(rows), 1);
            end
          end
          minGray = 0.05;
        end
        maxGray = 0.85;
      end
      
      % convert rows to double
      if islogical(rows)
        rows = find(rows);
      end
      % value extremes
      minValue = min( values );
      maxValue = max( values );
      % one value case -> no scaling
      if minValue == maxValue
        minValue = 0;
      end
      % calculate gray levels
      this.opts.grayLevelRow(rows) = ((values - minValue) / (maxValue-minValue)) ...
            * (maxGray - minGray) + minGray;
    end

    function stringTable = toStringTable(this)
      % generate a cell array of strings which would go into the final
      % table (after separating them with '&')
      stringTable = {};
      isHeaderRow = 0;
      isHeaderCol = 0;

      if (~isempty(this.headerCol))
        isHeaderCol = 1;
      end
      if (~isempty(this.headerRow))
        % ensure row cell-array
        stringTable = this.headerRow(:)';
        isHeaderRow = 1;
      end

      for row = 1:(this.getNRows())
        if (isHeaderCol)
          stringTable{row+isHeaderRow, 1} = this.headerCol{row};
        end
        
        for col = 1:(this.getNCols())
          dataValue = this.data{row, col};
          if isnan(dataValue)
            dataValue = this.opts.dataNanString;
          elseif (isnumeric(dataValue) || ischar(dataValue) || islogical(dataValue))
            if (~isempty(this.formats{row, col}))
              thisFormat = this.formats{row, col};
            elseif (isnumeric(dataValue))
              thisFormat = this.opts.numericFormat;
            elseif (islogical(dataValue))
              thisFormat = '%d';
            else
              thisFormat = '%s';
            end
            % if (~isempty(dataValue))
              dataValue = sprintf(thisFormat, dataValue);
            % else
            %  dataValue = '';
            % end
          end
          stringTable{row+isHeaderRow, isHeaderCol + col} = dataValue;
        end
      end
    end
    
    function latex = toStringRows(this, stringTable)
      % from the cell array of final LaTeX strings, generate the
      % final LaTeX code into 'latex' -- cell array of lines of code
      %
      % latex = toStringRows(this) - generate the final LaTeX code
      %
      % latex = toStringRows(this, stringTable) - generate the final LaTeX
      %                                           code from 'stringTable'
      %
      % Input:
      %   stringTable - array of individual table cells | cell-array of
      %                 string
      %
      % Output:
      %   latex - lines of table LaTeX code | cell-array of string

      if nargin < 2
        stringTable = this.toStringTable;
      end
      % ensure all cell-array fields are string
      assert(iscell(stringTable), 'usefun:LatexTable:ncellInput', ...
        'Input is not a cell-array');
      if any(any( ~cellfun(@ischar, stringTable) ))
        warning('usefun:LatexTable:ncellChInput', ...
          ['There is a cell containing non-char variable. ', ...
           'All such cells will be replaced by '''''])
        stringTable(~cellfun(@ischar, stringTable)) = {''};
      end

      % make table header lines:
      hLine = '\hline';
      latex = {};
      if (this.opts.latexHeader)
        latex = {['\begin{table}',this.opts.tablePlacement]; '\centering'};
        if (~isempty(this.opts.tableCaption))
          latex{end+1} = ['\caption{',this.opts.tableCaption,'}'];
        end
        if (~isempty(this.opts.tableLabel))
          latex{end+1} = ['\label{table:',this.opts.tableLabel,'}'];
        end
      end
      % set up the alignment string
      if (ischar(this.opts.tableColumnAlignment))
        this.opts.tableColumnAlignment = {this.opts.tableColumnAlignment};
      end
      if (length(this.opts.tableColumnAlignment) == 1)
        align = repmat(this.opts.tableColumnAlignment, 1, this.getNCols());
      else
        align = this.opts.tableColumnAlignment;
      end
      if (this.opts.tableBorders)
        header = ['\begin{tabular}','{|',strjoin(align, '|'),'|}'];
      else
        header = ['\begin{tabular}','{',strjoin(align, ''),'}'];
      end
      latex{end+1} = header;

      % generate table itself
      if (this.opts.booktabs)
        latex(end+1) = {'\toprule'};
      else
        if (this.opts.tableBorders)
          latex(end+1) = {hLine};
        end
      end

      % identify the maximal widths of columns for the right text alignment
      % of the '&' characters
      colWidths = zeros(size(stringTable, 2));
      for j = 1:size(stringTable, 2)
        colWidths(j) = 0;
        for i = 1:size(stringTable, 1)
          colWidths(j) = max(colWidths(j), length(stringTable{i,j}));
        end
      end

      % generate the table line-by-line
      for i = 1:size(stringTable, 1)
        thisRow = '';
        skip = 0;
        nCols = size(stringTable, 2);
        
        for j = 1:nCols
          % check for \multicolumn command
          [~, multiCols] = regexp(stringTable{i,j}, '\\multicolumn{([0-9]+)}', 'match', 'tokens');
          % print stringTable field
          thisRow = [thisRow sprintf(['%' num2str(colWidths(j)) 's'], stringTable{i,j})];
          % print separator according to \multicolumn presence
          if (~isempty(multiCols) && str2num(multiCols{1}{1}) > 1)
            skip = skip + (str2num(multiCols{1}{1}) - 1);
            thisRow = [thisRow, '   '];
          elseif (j < nCols)
            thisRow = [thisRow, ' & '];
          end
          % if (j >= nCols - skip)
          %   break;
          % end
        end
        latex{end+1} = [thisRow ' \\'];

        % insert defined middle lines
        if any(i == this.opts.midLines)
          if (this.opts.booktabs)
            latex{end+1} = '\midrule';
          elseif (this.opts.tableBorders)
            latex(end+1) = {hLine};
          end
        end
        
        % insert defined coloring
        if (numel(this.opts.grayLevelRow) >= i) && (this.opts.grayLevelRow(i) > 0)
          latex{end+1} = sprintf('\\rowcolor[gray]{%.4f}', this.opts.grayLevelRow(i));
        end
      end
 
      % final line of the table
      if (this.opts.booktabs)
        latex(end+1) = {'\bottomrule'};
      elseif (this.opts.tableBorders)
        latex(end+1) = {hLine};
      end
      latex(end+1) = {'\end{tabular}'};

      if (this.opts.latexHeader)
        % make footer lines for table:
        latex(end+1) = {'\end{table}'};
      end
    end
    
    function [ok, err] = toFile(this, filename)
      % print table to specified file
      if nargin < 2
        filename = 'latexTable.tex';
      end
      
      latexRows = this.toStringRows(this.toStringTable);
      % save the result in the file
      ok = false;
      err = [];
      try
        fid = fopen(filename, 'w');
        for i = 1:length(latexRows)
          fprintf(fid, '%s\n', latexRows{i});
        end
        fclose(fid);
        ok = true;
        fprintf('Table saved to %s\n', filename)
      catch err
        warning(err.identifier, 'Could not save table due to the following error: %s', err.message)
      end
    end
  end
end
