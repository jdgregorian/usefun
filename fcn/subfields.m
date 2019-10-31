function sf = subfields(thisStruct)
% sf = subfields(ThisStruct) returns cell array of all field and subfield
% names of structure ThisStruct except structure names.
%
% See Also:
%   printStructure

   sf = fieldnames(thisStruct);
   Nsf = length(sf);
   deletesf = false(1,Nsf);
   
   for fnum = 1:Nsf
     actStruct = thisStruct.(sf{fnum});
     % continue only if the field is non-empty structure
     if isstruct(actStruct) && ~isempty(fieldnames(actStruct))
       sDim = ndims(actStruct);
       sSizes = zeros(sDim, 1);
       [sSizes(:)] = size(actStruct);
       % single structure case
       if all(sSizes == 1)
         sf = catSub(actStruct, sf, fnum, '');
       % structure row vector
       elseif sSizes(1) == 1 && all(sSizes(3:end) == 1)
         for v = 1:sSizes(2)
           sf = catSub(actStruct(v), sf, fnum, ['(', num2str(v), ')']);
         end
       % structure array
       else
         positionVec = [ones(sDim-1, 1); 0];
         for i = 1:prod(sSizes);
           % increase position number
           positionVec = incPos(positionVec, sSizes);
           positionStr = sprintf('%d,', positionVec);
           sf = catSub(actStruct(positionVec), sf, fnum, ['(', positionStr(1:end-1), ')']);
         end
       end
       % mark field as possible to delete
       deletesf(fnum) = true;
     end
   end
   % delete higher structure names
   sf(deletesf) = [];

end

function sf = catSub(ThisStruct, sf, fnum, structStr)
% function concatenates structure subfields
  cn = subfields(ThisStruct);
  sf = cat(1, sf, strcat(sf{fnum}, structStr, '.', cn));
end

function position = incPos(position, sizeVector)
% function increases position number in terms of sizeVector
  dimNumber = numel(position);
  while ( dimNumber > 0 ) && ( position(dimNumber) + 1 > sizeVector(dimNumber) )
    position(dimNumber) = 1;
    dimNumber = dimNumber - 1;
  end
  % position outside defined sizeVector
  if dimNumber == 0
    position = NaN(size(position));
  % position inside sizeVector
  else
    position(dimNumber) = position(dimNumber) + 1;
  end
end