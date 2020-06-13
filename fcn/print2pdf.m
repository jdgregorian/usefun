function print2pdf(handles, pdfname, overwrite)
% PRINT2PDF Print figures to pdf in format displayed on the screen.
%   PRINT2PDF(handles) print figures to pdf to current folder named
%   figure1.pdf, figure2pdf, ...
%
%   PRINT2PDF(handles, pdfname) print figures to pdf to files defined in
%  ''pdfname''.
%
%   PRINT2PDF(handles, pdfname, overwrite) automatically overwrite figures
%   in files defined in ''pdfname'' according to ''overwrite'' variable
%   (true or false).
%
% Input:
%   handles   - handles of figures | handle or cell-array of handles
%   pdfname   - resulting filenames | string or cell array of strings
%   overwrite - automatically overwrite without asking | boolean | double

  if nargin < 1
    help print2pdf
    return
  end

  nFig = length(handles);
  if nFig == 0
    warning('usefun:print2pdf:emptyInput', 'Zero number of handles.')
    return
  elseif nargin < 2 || isempty(pdfname)
    pdfname = cell(1, nFig);
    for f = 1:nFig
      pdfname{f} = ['figure', num2str(f), '.pdf'];
    end
  end
  % pass handle input to cell-array
  if ishandle(handles)
    handles = num2cell(handles);
  end
  if ischar(pdfname)
    pdfname = {pdfname};
  end
  % check variable validity
  assert(iscell(handles) && all(cellfun(@ishandle, handles)), ...
    'usefun:print2pdf:wrongHandleInput', ...
    'Input variable ''handles'' has to be handle or cell-array of handles.')
  assert(iscell(pdfname) && all(cellfun(@ischar, pdfname)), ...
    'usefun:print2pdf:wrongPdfnameInput', ...
    'Input variable ''pdfname'' has to be string or cell-array of strings.')

  nNames = length(pdfname);
  % check if names end with .pdf
  for f = 1:nNames
    if ~strcmp(pdfname{f}(end-3:end),'.pdf')
      pdfname{f} = [pdfname{f},'.pdf'];
    end
  end

  % check if there is enough names
  if nNames ~= nFig
    if nNames == 1
      fprintf('Creating names:\n\n')
      pdfname(1:nFig) = pdfname;
      for f = 1:nFig
        pdfname{f} = [pdfname{f}(1:end-4),num2str(f),pdfname{f}(end-3:end)];
        fprintf('%s\n',pdfname{f})
      end
    else
    error('usefun:print2pdf:nFigNames', 'Numbers of figures and names does not agree!')
    end
  end

  % count existing files
  existingPDFs = [];
  for f = 1:nFig
    pdfFolder = fileparts(pdfname{f});
    if ~exist(pdfFolder, 'dir')
      [~, ~] = mkdir(pdfFolder);
    elseif exist(pdfname{f},'file')
      existingPDFs(end+1) = f;            
    end
  end
  NexistPDF = length(existingPDFs);

  if nargin < 3
    % ask for overwritting previous images (if there were any)
    if any(existingPDFs)
        answer = questdlg(['Overwrite pdfs for ',num2str(NexistPDF),' files?'],'Overwritting old files','Overwrite','No','Overwrite');
        if strcmp('Overwrite',answer)
            overwrite = 1;
        else
            overwrite = 0;
        end
    else
        overwrite = 1;
    end
  end 

  % print plot to pdf
  if overwrite
    for f = 1:nFig
      set(handles{f},'PaperPositionMode','auto')
      print(handles{f},'-dpdf','-r0',pdfname{f});
    end
  else
    for f = 1:NexistPDF
      set(handles{existingPDFs(f)},'PaperPositionMode','auto')
      print('-dpdf','-r0',pdfname{existingPDFs(f)});
    end
  end

end