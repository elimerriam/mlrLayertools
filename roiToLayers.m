% roiToLayers.m
%
%      usage: roiToLayers()
%         by: eli merriam
%       date: 02/19/20
%    purpose: 
%
%  Step 1: Generate equidistant surfaces using makeEquiSurfaces
%  Step 2: Use this code to project an ROI through these surfaces and save MLR rois
%  
%  Needs to be run while viewing a surface at cortical depth 0, with the ROI that you which to project
%
function retval = roiToLayers()

% check arguments
if ~any(nargin == [0])
  help roiToLayers
  return
end

hemi = 'lh';

base = viewGet(getMLRView, 'base');
vtcs = base.coordMap.innerVtcs;

surf = loadSurfOFF(sprintf('/misc/data58/merriamep/data/freesurfer/s0100_hires/surfRelax/%s.equi1.0.off', hemi));
surf = xformSurfaceWorld2Array(surf,base.hdr);

c = viewGet(getMLRView, 'roicoords');

for iCoord = 1:length(c);
  [nearest(iCoord), distances(iCoord)] = assignToNearest(surf.vtcs, c(1:3,iCoord)');
end

disp(sprintf('Median distance: %f, Max distance: %f', median(distances), max(distances))); 

depths = 0:0.1:1;
% colors for rois
layerColors = hsv(length(depths));

for iDepth=1:length(depths)
  surf = loadSurfOFF(sprintf('/misc/data58/merriamep/data/freesurfer/s0100_hires/surfRelax/%s.equi%01.1f.off',hemi, depths(iDepth)));
  surf = xformSurfaceWorld2Array(surf,base.hdr);
  
  vtcs = surf.vtcs(nearest,:);
  
  % make an roi
  roi.color = layerColors(iDepth,:);
  roi.name = sprintf('%sEqui%0.1f', hemi, depths(iDepth));
  roi.voxelSize = base.hdr.pixdim(2:4);
  % get xform - either sform if set, or qform
  if ~isempty(base.hdr.sform44) && (base.hdr.sform_code ~= 0)
    roi.xform = base.hdr.sform44;
  else
    roi.xform = base.hdr.qform44;
  end
  roi.createdBy = 'roiToLayers';
  [tf roi] = isroi(roi);
  if ~tf,keyboard,end

  coords = round(vtcs);
  
  clear uniqueCoords;
  % get unique coords
  dims(1) = base.coordMap.dims(2);
  dims(2) = base.coordMap.dims(1);
  dims(3) = base.coordMap.dims(3);
  coordsIndex = unique(sub2ind(dims,coords(:,1),coords(:,2),coords(:,3)));
  [uniqueCoords(:,1) uniqueCoords(:,2) uniqueCoords(:,3)] = ind2sub(dims,coordsIndex);

  % put these coords into the roi
  roi.coords = uniqueCoords';
  
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
