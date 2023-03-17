% computeVasoDiffRuns.m
%
%      usage: computeVasoDiffRuns(getMLRView, 1, 2) 
%         by: eli & elena
%       date: 04/22/20
%    purpose:
%
function retval = computeVasoDiffRuns(v, nulledScanNum, boldScanNum)

% check arguments
if ~any(nargin == [3])
    help computeVasoDiffRuns
    return
end

disp(sprintf('Computing vaso on Scans %i and %i', nulledScanNum, boldScanNum));

% these are the data we are analyzing
v = viewSet(v, 'curGroup', 'Averages');

% load the data from the appropriate group
bold = loadTSeries(v, boldScanNum);
nulled = loadTSeries(v, nulledScanNum);

% get the hdr info
hdr = viewGet(v, 'niftihdr', boldScanNum);

% load the scan params and nifti header
scanParams = viewGet(v, 'scanparams', boldScanNum);

% original size
[Nx Ny Nz Nt] = size(bold);

% upsample vnulledaso (forward for half of a TR)
[xgrid,ygrid,zgrid,tgrid] = ndgrid(1:Nx, 1:Ny, 1:Nz, 1:0.5:Nt+0.5);
% upsample nulled 
nulledUp = interpn(nulled, xgrid, ygrid, zgrid, tgrid, 'linear');
% upsample bold
boldUp = interpn(bold, xgrid, ygrid, zgrid, tgrid, 'linear');
boldUp = cat(4, boldUp(:,:,:,1), boldUp(:,:,:,end-1));

% compute vaso
dims = size(boldUp);
boldUp = reshape(boldUp, dims(1)*dims(2)*dims(3), dims(4));
dims = size(nulledUp);
nulledUp = reshape(nulledUp, dims(1)*dims(2)*dims(3), dims(4));

% loop over frames
vaso = zeros(size(nulledUp));
disppercent(-inf, 'Computing vaso')
for iFrame = 1:dims(4);
    vaso(:,iFrame) = nulledUp(:,iFrame) ./ boldUp(:,iFrame);
    disppercent(iFrame/dims(4));
end
disppercent(inf);

% clip unrealistic values
vaso(find(vaso<0)) = 0;
vaso(isnan(vaso))  = 0;
vaso(find(vaso>5)) = 5;

vaso = reshape(vaso, dims(1), dims(2), dims(3), dims(4));

% save
% create new groups
v = viewSet(v, 'newGroup', 'Vaso');
scanParams = viewGet(v, 'scanparams', nulledScanNum);
scanParams.fileName = [];
scanParams.totalFrames = size(vaso,4);

% switch the the Vaso group
scanParams.description = 'Vaso';
v = viewSet(v, 'curGroup', 'Vaso');
v = saveNewTSeries(v, vaso, scanParams, hdr);

saveSession();


