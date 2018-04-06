function ind = cvInd(n, k)
% ind = cvInd(n, k) generate k-fold cross-validation indices for n objects

  if nargin < 2
    if nargin < 1
      help cvInd
      return
    end
    k = 5;
  end

  assert(isnumeric(k) && k >= 1, 'cvInd: k is not valid')
  assert(isnumeric(n) && n >= 1, 'cvInd: n is not valid')

  ind = zeros(n,1);
  % compute fold indices for all objects
  fInd = ceil(k*(1:n) / n);
  % permute fold id's
  permFInd = randperm(k);
  % randomly assign identifiers to the objects
  randInd = randperm(n);
  hInd = 1:n;
  ind(hInd(randInd)) = permFInd(fInd);

end