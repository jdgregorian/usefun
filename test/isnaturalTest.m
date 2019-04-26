function tests = isnaturalTest
  tests = functiontests(localfunctions);
end

function testEmptyInput(testCase) 
% test empty input  
  verifyError(testCase, @isnatural, 'usefun:isnatural:nEnoughInput')
  verifyEmpty(testCase, isnatural([]))
end

function testNaNInfInput(testCase)
% test NaN or Inf input
  verifyFalse(testCase, isnatural(NaN))
  verifyFalse(testCase, isnatural(Inf))
end

function testDifferentType(testCase)
% test input of non-numeric type

  % only characters can return false value
  verifyFalse(testCase, isnatural('1'))
  
  % test wrong input of N and Z
  verifyError(testCase, @() isnatural(1, -3), 'usefun:isnatural:boundNatural')
  verifyError(testCase, @() isnatural(1, 3, '3'), 'usefun:isnatural:zeroNum')
end

function testResult(testCase) 
% test valid results
  XX = [-1 0 1+2i; 2.2 3 8; pi NaN -Inf];
  
  % natural numbers
  res = isnatural(XX);
  verifySize(testCase, res, [3, 3])
  verifyEqual(testCase, res, logical([ 0 0 0; 0 1 1; 0 0 0]))
  
  % natural numbers in range [1, N]
  N = 4;
  res = isnatural(XX, N);
  verifySize(testCase, res, [3, 3])
  verifyEqual(testCase, res, logical([ 0 0 0; 0 1 0; 0 0 0]))
  
  % natural numbers in range [0, N]
  res = isnatural(XX, N, 0);
  verifySize(testCase, res, [3, 3])
  verifyEqual(testCase, res, logical([ 0 1 0; 0 1 0; 0 0 0]))
end