function value = defoptsi(structOpts, fieldName, defValue)
  % value = defoptsi(structOpts, fieldName, defValue)
  % Return either value specified in lower case structOpts.(fieldName) 
  % (if specified) or  'defValue'  (otherwise).
  value = defopts(lowerFieldnames(structOpts), lower(fieldName), defValue);
end
