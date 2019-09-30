function tests = licolsTest
  tests = functiontests(localfunctions);
end

function testEmptyInput(testCase) 
% test empty input

  % no input
  [Xsub, idx] = licols();
  verifyEmpty(testCase, Xsub)
  verifyEmpty(testCase, idx)
  
  % empty input
  [Xsub, idx] = licols([]);
  verifyEmpty(testCase, Xsub)
  verifyEmpty(testCase, idx) 

  X = [1,1,2; 1,2,3; 2,3,5];
  % empty tolerance
  verifyError(testCase, @() licols(X, []), 'usefun:licols:positiveTol');

  % not given tolerance
  [Xsub, idx] = licols(X);
  verifyEqual(testCase, Xsub, [1,2; 2,3; 3,5])
  verifyEqual(testCase, idx, [2, 3]) 
end

function testWrongInput(testCase)
% test inconvenient input

  % char input
  X = ['111'; '222'; '333'];
  verifyError(testCase, @() licols(X), 'usefun:licols:numInput')
  
  % wrong tolerance
  verifyError(testCase, @() licols(X, 0), 'usefun:licols:positiveTol');
  verifyError(testCase, @() licols(X, 'a'), 'usefun:licols:positiveTol');
  verifyError(testCase, @() licols(X, struct()), 'usefun:licols:positiveTol');
end

function testNaNInfInput(testCase) 
% test NaN or Inf input - considered to be linearly independent

  X = [1,1,2; 1,2,3; 2,3,5];
  
  % nan input
  Xnan = [NaN; 1; 1];
  [Xsub, idx] = licols([X, Xnan]);
  verifyEqual(testCase, Xsub, [X(:, 2:3), Xnan])
  verifyEqual(testCase, idx, [2, 3, 4]) 
  
  % Inf input
  Xinf = [Inf; 1; 1];
  [Xsub, idx] = licols([X, Xinf]);
  verifyEqual(testCase, Xsub, [X(:, 2:3), Xinf])
  verifyEqual(testCase, idx, [2, 3, 4]) 

end

function testZeroMatrix(testCase)
% test zero matrix as an input
  
  % only zero matrix
  [Xsub, idx] = licols(zeros(3));
  verifyEmpty(testCase, Xsub)
  verifyEmpty(testCase, idx)

  % only zero vertical vector
  [Xsub, idx] = licols(zeros(3, 1));
  verifyEmpty(testCase, Xsub)
  verifyEmpty(testCase, idx)
  % only zero horizontal matrix
  [Xsub, idx] = licols(zeros(1, 3));
  verifyEmpty(testCase, Xsub)
  verifyEmpty(testCase, idx)

  % zero matrix with NaN or Inf columns
  Xnan = [NaN; 1; 2];
  [Xsub, idx] = licols([Xnan, zeros(3)]);
  verifyEqual(testCase, Xsub, Xnan)
  verifyEqual(testCase, idx, 1)

end

function testOneVector(testCase)
% test one vector input

  % horizontal vector
  v = [1, 2, 3];
  [Xsub, idx] = licols(v);
  verifyEqual(testCase, Xsub, v(end))
  verifyEqual(testCase, idx, numel(v))

  % vertical vector
  [Xsub, idx] = licols(v');
  verifyEqual(testCase, Xsub, v')
  verifyEqual(testCase, idx, 1)

end
