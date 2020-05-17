function tests = printHelpFilesTest
  tests = functiontests(localfunctions);
end

function testInput(testCase)
% test input

  helpFolder = 'fcn';
  texFolder = fullfile('test_doc', 'tex');
  filename = fullfile(texFolder, 'test_function_help.tex');
  
  % make testing direrctory
  mkdir(texFolder)

  % empty input
  printHelpFiles(filename, helpFolder);
  % file exists
  fileExists = isfile(filename);
  verifyTrue(testCase, fileExists)
  % delete created file and folder
  rmdir('test_doc', 's')
end