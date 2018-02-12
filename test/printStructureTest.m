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