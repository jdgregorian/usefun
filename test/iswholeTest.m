function tests = iswholeTest
  tests = functiontests(localfunctions);
end

function testEmptyInput(testCase) 
% test empty input  
  verifyError(testCase, @iswhole, 'usefun:iswhole:nEnoughInput')
  verifyEmpty(testCase, iswhole([]))
end

function testNaNInfInput(testCase)
% test NaN or Inf input
  verifyFalse(testCase, iswhole(NaN))
  verifyFalse(testCase, iswhole(Inf))
end

function testDifferentType(testCase)
% test input of non-numeric type

  % only characters can return false value
  verifyFalse(testCase, iswhole('1'))
  % other classes should cause error
  verifyError(testCase, @() iswhole({}), 'usefun:iswhole:undefined')
  verifyError(testCase, @() iswhole({1}), 'usefun:iswhole:undefined')
  verifyError(testCase, @() iswhole(table()), 'usefun:iswhole:undefined')
  verifyError(testCase, @() iswhole(struct()), 'usefun:iswhole:undefined')
  verifyError(testCase, @() iswhole(@() 1), 'usefun:iswhole:undefined')
end

function testResult(testCase) 
% test valid results
  XX = [1.1, 2, 3; ...
        4, pi, 6; ...
        7, 8, 1+1i];
  verifySize(testCase, iswhole(XX), [3, 3])
  verifyFalse(testCase, any(iswhole(diag(XX))) )
  verifyTrue(testCase, all(iswhole(XX(~eye(3)))) )
end