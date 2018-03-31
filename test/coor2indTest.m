function tests = coor2indTest
  tests = functiontests(localfunctions);
end

function testEmptyInput(testCase) 
% test empty input
  verifyEmpty(testCase, coor2ind())
  verifyEmpty(testCase, coor2ind(15))
end

function testResult(testCase) 
% test valid results
  dim = 4;
  matSize = randi(2*dim, 1, dim);
  coor = ceil(1/2*matSize);
  verifySize(testCase, coor2ind(coor, matSize), [1, 1])
end