function str = num2tex(num, dec)
% str = num2tex(num, dec) returns string created from number in form 
% convenient for tex printing.
%
% Input:
%   num - number to convert | double
%   dec - amount of numbers to show in converted result | positive non-zero
%         integer
%
% Output:
%   str - resulting number in tex format | string
%
% Example:
%   num = 15000000;
%   str = num2tex(num)
%   str =
%
%   1.5*10^{7}

  if nargin < 2 || isempty(dec)
    base_str = sprintf('%g', num);
  else
    base_str = sprintf(['%.', num2str(dec), 'g'], num);
  end
  
  eLoc = strfind(base_str, 'e');
  % number without exponent
  if isempty(eLoc)
    str = base_str;
  % number with exponent
  else
    % case '1'
    if strcmp(base_str(1:eLoc-1), '1')
      first_base = '';
    else
      first_base = [base_str(1:eLoc-1), '\cdot'];
    end
    % exponent sign difference
    if strcmp(base_str(eLoc+1), '+')
      str = sprintf('%s10^{%d}', first_base, str2double(base_str(eLoc+2:end)));
    else
      str = sprintf('%s10^{-%d}', first_base, str2double(base_str(eLoc+2:end)));
    end
  end
  
end