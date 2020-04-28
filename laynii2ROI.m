% laynii2ROI.m
%
%      usage: laynii2ROI()
%         by: eli merriam
%       date: 04/08/20
%    purpose: 
%
function retval = laynii2ROI(layermask)

% check arguments
if ~any(nargin == [1])
  help laynii2ROI
  return
end

[d,hdr] = cbiReadNifti(layermask);

depths = 1:max(d(:));

% colors for rois
layerColors = hsv(length(depths));
layerColors = circshift(hsv(length(depths)), [3 0]);

for iDepth = depths
  [x,y,z] = ind2sub(size(d), find(d==iDepth));

  % make an roi
  roi.color = layerColors(iDepth,:);
  roi.name = sprintf('lStimLayers%02.0f', iDepth);

  roi.voxelSize = hdr.pixdim(2:4);

  % get xform - either sform if set, or qform
  if ~isempty(hdr.sform44) && (hdr.sform_code ~= 0)
    roi.xform = hdr.sform44;
  else
    roi.xform = hdr.qform44;
  end

  roi.createdBy = 'roiToLayers';
  [tf roi] = isroi(roi);
  if ~tf,keyboard,end

  coords = [x y z]';

  roi.coords = coords;

  saveROI('ROIs',roi);

end

%%%%%%%%%%%%%%%%%
%    saveROI    %
%%%%%%%%%%%%%%%%%
function saveROI(saveDir,roi)

% make into cell array
roi = cellArray(roi);

% make the directory if it does not exist
if ~isdir(saveDir)
  mkdir(saveDir);
end

% for each roi, go and save
for iROI = 1:length(roi)
  % get the save name
  savename = fixBadChars(roi{iROI}.name,[],{'.','_'});
  eval(sprintf('%s = roi{iROI};',savename));
  save(fullfile(saveDir,savename),savename);
end

