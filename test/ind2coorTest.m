function tests = ind2coorTest
  tests = functiontests(localfunctions);
end

function testEmptyInput(testCase) 
% test empty input
  verifyEmpty(testCase, ind2coor())
  verifyEmpty(testCase, ind2coor(15))
end

function testResult(testCase) 
% test valid results
  dim = 4;
  matSize = randi(2*dim, 1, dim);
  ind = ceil(1/2 * prod(matSize));
  verifySize(testCase, ind2coor(ind, matSize), [1, dim])
end