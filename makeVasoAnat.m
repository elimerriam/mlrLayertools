% makeVasoAnat.m
%
%      usage: makeVasoAnat()
%         by: eli merriam
%       date: 10/25/18
%    purpose: 
%
function retval = makeVasoAnat()

% check arguments
if ~any(nargin == [0])
  help makeVasoAnat
  return
end

% create a new view and get some info
v = newView;
v = viewSet(v, 'curGroup', 'MotionComp');  
nScans = viewGet(v, 'nScans', 'MotionComp');
hdr = viewGet(v, 'niftihdr', 1);
junkFrames = 0;
upFac = 4;

hdr.sform44 = hdr.qform44;

v = viewSet(v, 'curGroup', 'MotionComp');  
disppercent(-1/nScans, 'Looping over tSeries');
for iScan = 1:nScans
  % load the tSeries
  tSeries = loadTSeries(v, iScan);
  dims = size(tSeries);
  nFrames = dims(4);
  % remove junk frames
  tSeries = tSeries(:,:,:,junkFrames+1:nFrames);
  cvar(:,:,:,iScan) = 1 / (std(tSeries,[],4) ./ abs(mean(tSeries,4)));
end
disppercent(inf);

vasoAnat = median(cvar,4);

% set the file extension
niftiFileExtension = '.nii';

% Path
pathStr = fullfile(viewGet(view,'anatomydir'),['vasoAnatOrig',niftiFileExtension]);

disp(sprintf('Saving %s...',pathStr));
cbiWriteNifti(pathStr, vasoAnat, hdr);

% Delete temporary views
deleteView(v);

% denoise and correct data
system('DenoiseImage -d 3 -n Rician -i Anatomy/vasoAnatOrig.nii -o Anatomy/vasoAnatDenoised.nii');
system(sprintf('N4BiasFieldCorrection -i Anatomy/vasoAnatDenoised.nii -o Anatomy/vasoAnat.nii'));

evalStr = sprintf('system(''ResampleImage 3 Anatomy/vasoAnat.nii Anatomy/vasoAnatUpsample.nii %ix%ix%i 1 4'')', dims(1)*upFac, dims(2)*upFac, dims(3));
eval(evalStr);

% cleanup
system('rm -f Anatomy/vasoAnatOrig.nii Anatomy/vasoAnatDenoised.nii');




