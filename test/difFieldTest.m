function tests = difFieldTest
  tests = functiontests(localfunctions);
end

function testEmptyFields(testCase) 
% test differences with empty or missing fields of structures
  s1.a = 1;
  s1.b = 'txt';
  s1.c = {4, '2'};
  
  s2.a = 1;
  s2.b = [];
  s2.c = {4, '2'};
  
  s3.a = 1;
  s3.c = {4, '2'};
  
  s4.a = 1;
  s4.b = {};
  s4.c = {4, '2'};
  
  % empty field in one structure
  [df, dVal, emptyVal] = difField(s1, s2);
  verifyEqual(testCase, df, {'b'});
  verifyEqual(testCase, dVal, {'txt', []}); 
  verifyEqual(testCase, emptyVal, logical([0 1]));
  
  % non-exiting field in one structure 
  [df, dVal, emptyVal] = difField(s2, s3);
  verifyEqual(testCase, df, {'b'});
  verifyEqual(testCase, dVal, {[], []}); 
  verifyEqual(testCase, emptyVal, logical([1, 0]));
  
  % empty field in all structures  
  [df, dVal, emptyVal] = difField(s2, s2);
  verifyEmpty(testCase, df);
  verifyEmpty(testCase, dVal);
  verifyEmpty(testCase, emptyVal);
  
  % empty cell field in one structure
  [df, dVal, emptyVal] = difField(s1, s4);
  verifyEqual(testCase, df, {'b'});
  verifyEqual(testCase, dVal, {'txt', {}}); 
  verifyEqual(testCase, emptyVal, logical([0, 1]));
  
  % comparison of empty cell and empty double field
  [df, dVal, emptyVal] = difField(s2, s4);
  verifyEqual(testCase, df, {'b'});
  verifyEqual(testCase, dVal, {[], {}}); 
  verifyEqual(testCase, emptyVal, logical([1, 1]));
  
end

function testNaNFields(testCase) 
% test differences with empty or missing fields of structures

  s1.a = 1;
  s1.b = 'txt';
  s1.c = {1, {}};
  s1.d.e = struct();

  s2.a = 1;
  s2.b = NaN;
  s2.c = {1, NaN};
  s2.d.e = NaN;
  
  s3.a = 1;
  s3.b = NaN;
  s3.c = {1, NaN};
  
  % NaN vs. ordinary values
  [df, dVal, emptyVal] = difField(s1, s2);
  verifyEqual(testCase, df, {'b'; 'c'; 'd.e'});
  verifyEqual(testCase, dVal, {'txt', NaN; {1, {}}, {1, NaN}; struct(), NaN}); 
  verifyEqual(testCase, emptyVal, logical([0, 0; 0, 0; 0, 0]));
  
  % same field NaN values
  [df, dVal, emptyVal] = difField(s2, s2);
  verifyEmpty(testCase, df);
  verifyEmpty(testCase, dVal); 
  verifyEmpty(testCase, emptyVal);
  
  % one NaN field missing
  [df, dVal, emptyVal] = difField(s2, s3);
  verifyEqual(testCase, df, {'d.e'});
  verifyEqual(testCase, dVal, {NaN, []}); 
  verifyEqual(testCase, emptyVal, logical([0, 0]));
  
end