% roi2Vol.m
%
%      usage: roi2Vol()
%         by: eli merriam
%       date: 04/09/20
%    purpose: 
%
function retval = roi2Vol()

% check arguments
if ~any(nargin == [0])
  help roi2Vol
  return
end

coords = viewGet(getMLRView, 'roicoords');

dims = viewGet(getMLRView, 'basedims');

hdr = viewGet(getMLRView, 'basehdr');

newvol = zeros(dims);

ind = sub2ind(dims, coords(1,:), coords(2,:), coords(3,:));

newvol(ind) = 1;

roiname = viewGet(getMLRView, 'roiname');

cbiWriteNifti(sprintf('Anatomy/%s.nii', roiname), newvol, hdr);


