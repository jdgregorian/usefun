function tests = repStructValTest
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
  s3.b = {};
  s3.c = {4, '2'};
  
  ov1 = 1;
  ov2 = [];
  ov3 = 2;
  
  nv1 = 3;
  
  % no empty field in structure or values
  sNew = repStructVal(s1, ov1, nv1);
  verifyEqual(testCase, sNew.a, nv1);
  
  % non-exiting value in structure 
  sNew = repStructVal(s1, ov3, nv1);
  verifyEqual(testCase, sNew, s1);
  
  % empty field in structure  
  sNew = repStructVal(s2, ov1, nv1);
  verifyEqual(testCase, sNew.a, nv1);
  verifyEmpty(testCase, sNew.b);
  
  % empty cell field in one structure
  sNew = repStructVal(s3, ov1, nv1);
  verifyEqual(testCase, sNew.a, nv1);
  verifyEmpty(testCase, sNew.b);
  
  % replace empty field by different value
  sNew = repStructVal(s2, ov2, nv1);
  verifyEqual(testCase, sNew.b, nv1);
  
end

function testNaNFields(testCase) 
% test NaN values in fields of structures or original values
  s1.a = 1;
  s1.b = 'txt';
  s1.c = {1, {}};
  s1.d.e = struct();

  s2.a = 1;
  s2.b = NaN;
  s2.c = {1, NaN};
  s2.d.e = NaN;
  
  ov1 = 1;
  ov2 = NaN;
  ov3 = {1, NaN};
  
  nv1 = 3;
  
  % no NaN field in structure vs NaN value
  sNew = repStructVal(s1, ov2, nv1);
  verifyEqual(testCase, sNew, s1);
  
  % NaN field in structure vs NaN value
  sNew = repStructVal(s2, ov2, nv1);
  verifyEqual(testCase, sNew.a, s2.a);
  verifyEqual(testCase, sNew.b, nv1);
  verifyEqual(testCase, sNew.c, s2.c);
  verifyEqual(testCase, sNew.d.e, nv1);
  
  % NaN field in structure vs NaN value in cell
  sNew = repStructVal(s2, ov3, nv1);
  verifyEqual(testCase, sNew.a, s2.a);
  verifyEqual(testCase, sNew.b, s2.b);
  verifyEqual(testCase, sNew.c, nv1);
  verifyEqual(testCase, sNew.d, s2.d);
  
end

function testCondition(testCase) 
% test conditions on fields of structures
  s1.a = 1;
  s1.b = [];
  s1.c = {4, '2'};

  s2.a = 1;
  s2.b = NaN;
  s2.c = {1, NaN};
  s2.d.e = NaN;
  
  cond1 = @isempty;
  cond2 = @isnan;
  
  nv1 = 3;
  
  % isempty condition on structure with empty fields
  sNew = repStructVal(s1, cond1, nv1, 'test');
  verifyEqual(testCase, sNew.a, s1.a);
  verifyEqual(testCase, sNew.b, nv1);
  verifyEqual(testCase, sNew.c, s1.c);
  
  % isempty condition on structure with not empty fields
  sNew = repStructVal(s2, cond1, nv1, 'test');
  verifyEqual(testCase, sNew, s2);
  
  % isnan condition on structure with NaN fields
  sNew = repStructVal(s2, cond2, nv1, 'test');
  verifyEqual(testCase, sNew.a, s2.a);
  verifyEqual(testCase, sNew.b, nv1);
  verifyEqual(testCase, sNew.c, s2.c);
  verifyEqual(testCase, sNew.d.e, nv1);
  
  % isempty condition on structure with not NaN fields
  sNew = repStructVal(s1, cond2, nv1, 'test');
  verifyEqual(testCase, sNew, s1);
  
end