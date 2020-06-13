function tests = print2pdfTest
  tests = functiontests(localfunctions);
end

function testEmptyInput(testCase) 
% test empty input

  % no input should not cause error
  print2pdf()
  
  % empty handles should cause warning
  verifyWarning(testCase, @() print2pdf([]), 'usefun:print2pdf:emptyInput')
  
  % empty pdfnames should not cause error
  h = figure();
  defFilename = 'figure1.pdf';
  % ensure no harm to original file
  if isfile(defFilename)
    testDir = fullfile(fileparts(which(mfilename)), 'print2pdfTestDir');
    mkdir(testDir)
    origFileCopy = fullfile(testDir, defFilename);
    copyfile(defFilename, origFileCopy)
    delete(defFilename)
  end
  
  plot(1:11, -5:5)
  print2pdf(h, [])
  verifyTrue(testCase, isfile(defFilename))
  
  % finalize
  delete(defFilename)
  close(h)
  % return original file if existed before test
  if isfile(origFileCopy)
    copyfile(origFileCopy, defFilename)
    delete(origFileCopy)
    rmdir(testDir)
  end
end

function testDifferentType(testCase)
% test input of incorrect type
  
  % init
  h = figure();
  % gain no handle number
  noHandle = randi(intmax);
  while ishandle(noHandle)
    noHandle = randi(intmax);
  end

  % test wrong input of 'handles' and 'pdfname'
  verifyError(testCase, @() print2pdf(noHandle), 'usefun:print2pdf:wrongHandleInput')
  verifyError(testCase, @() print2pdf(h, 3), 'usefun:print2pdf:wrongPdfnameInput')
  
  % finalize
  close(h)
end