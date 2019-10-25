classdef TestClass
% testing class
   properties
      Property
   end
   properties (Constant)
      ConstantProperty = 'const'
   end
   properties (Dependent)
      DependentProperty
   end
   
   methods
      function obj = testClass(var)
         if nargin > 0
            obj.Property = var;
         end
      end
      
      function val = get.DependentProperty(obj)
         val = {obj.ConstantProperty, obj.Property};
      end
      
      function obj = set.Property(obj, val)
         if isempty
            error('Property must not be empty')
         end
         obj.Property = val;
      end
      
      function disp(obj)
         fprintf('Test object with property: \n')
         disp(obj.Property)
      end
   end
   
end