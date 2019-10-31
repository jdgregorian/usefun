function tests = printStructureTest
  tests = functiontests(localfunctions);
end

function testChar(testCase)
% test char input

  % empty char
  s = '';
  str = printStructure(s);
  verifyEqual(testCase, str, sprintf('s = '''';\n'))
end

function testDouble(testCase)
% test double input

  % complex number
  s = 1i;
  str = printStructure(s);
  verifyEqual(testCase, str, sprintf('s = 0+1i;\n'))
end

function testTable(testCase) 
% test table input

  % empty table
  s = table();
  str = printStructure(s);
  verifyEqual(testCase, str, sprintf('s = table();\n'))
  
  % table of char
  s = table({'a'; 'b'; 'c'}, {'d'; 'e'; 'f'}, 'VariableNames', {'x1', 'x2'}, 'RowNames', {'r1', 'r2', 'r3'});
  str = printStructure(s);
  verifyEqual(testCase, str, sprintf(...
    ['s = table({''a''; ''b''; ''c''}, {''d''; ''e''; ''f''}, ', ...
    '''VariableNames'', {''x1'', ''x2''}, ', ...
    '''RowNames'', {''r1''; ''r2''; ''r3''});\n']))
 
end

function testObject(testCase)
% test object input

  % empty TestClass
  s = TestClass();
  str = printStructure(s);
  verifyEqual(testCase, str, sprintf(...
    ['s = TestClass(''Property'', [], ''ConstantProperty'', ''const'',', ...
     ' ''DependentProperty'', {''const'', []});\n']))

end

function testStructureArray(testCase)
% test multidimensional structure input

  % one dimensional row vector
  s = [struct('a', 1), struct('a', 2)];
  str = printStructure(s);
  verifyEqual(testCase, str, ['s(1).a = 1;', char(10), 's(2).a = 2;', char(10)])

  % one dimensional column vector
  s = [struct('a', 1); struct('a', 2)];
  str = printStructure(s);
  verifyEqual(testCase, str, ['s(1,1).a = 1;', char(10), 's(2,1).a = 2;', char(10)])

  % multidimensional vector
  sm(1, 2, 1, 2).a = 1;
  str = printStructure(sm);
  verifyEqual(testCase, str, ['sm(1,1,1,1).a = [];', char(10), ...
                              'sm(1,1,1,2).a = [];', char(10), ...
                              'sm(1,2,1,1).a = [];', char(10), ...
                              'sm(1,2,1,2).a = 1;',  char(10)])
end