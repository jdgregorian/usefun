function structure = lowerFieldnames(structure)
% structure = lowerFieldnames(structure) lowers fieldnames of the
% structure.

  str = struct();
  
  fNames = fieldnames(structure);
  for f = 1:length(fNames)
    str.(lower(fNames{f})) = structure.(fNames{f});
  end
  
  assert(length(fNames) == length(fieldnames(str)), ...
         'Cannot convert fieldnames to lower case. Some fields are already defined.')
  structure = str;

end