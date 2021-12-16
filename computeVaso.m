% computeVaso.m
%
%      usage: computeVaso()
%         by: eli merriam
%       date: 04/22/20
%    purpose: 
%
function retval = computeVaso()

% check arguments
if ~any(nargin == [0])
  help computeVaso
  return
end


v = newView;
v = viewSet(v, 'curGroup', 'MotionComp');
nScans = viewGet(v, 'nScans');

% create new groups
v = viewSet(v, 'newGroup', 'Vaso');
v = viewSet(v, 'newGroup', 'Bold');

for iScan = 1:nScans
  % load the data from MotionComp group
  v = viewSet(v, 'curGroup', 'MotionComp');
  tSeries = loadTSeries(v, iScan);
  hdr = viewGet(v, 'niftihdr', iScan);
  
  boldfirst = [];
  
  if boldfirst
    disp('BOLD before nulled');
    % subset the correct frames
    bold = tSeries(:,:,:,1:2:end);
    nulled = tSeries(:,:,:,2:2:end);
    % load the scan params and nifti header
    scanParams = viewGet(v, 'scanparams', iScan);
    % original size
    [Nx Ny Nz Nt] = size(bold);
    % upsample bold (forward for half of a TR)
    [xgrid,ygrid,zgrid,tgrid] = ndgrid(1:Nx, 1:Ny, 1:Nz, 1:0.5:Nt+0.5);
    boldUp = interpn(bold, xgrid, ygrid, zgrid, tgrid, 'pchip');
    % upsample nulled (backward for half of a TR)
    [xgrid,ygrid,zgrid,tgrid] = ndgrid(1:Nx, 1:Ny, 1:Nz, 0.5:0.5:Nt);
    nulledUp = interpn(nulled, xgrid, ygrid, zgrid, tgrid, 'pchip');
  else
    disp('Nulled images before BOLD');
    % subset the correct frames
    nulled = tSeries(:,:,:,1:2:end);
    bold = tSeries(:,:,:,2:2:end);
    % load the scan params and nifti header
    scanParams = viewGet(v, 'scanparams', iScan);
    % original size
    [Nx Ny Nz Nt] = size(bold);
    % upsample nulled (forward for half of a TR)
    [xgrid,ygrid,zgrid,tgrid] = ndgrid(1:Nx, 1:Ny, 1:Nz, 1:0.5:Nt+0.5);
    nulledUp = interpn(nulled, xgrid, ygrid, zgrid, tgrid, 'pchip');
    % upsample bold (backward for half of a TR)
    [xgrid,ygrid,zgrid,tgrid] = ndgrid(1:Nx, 1:Ny, 1:Nz, 0.5:0.5:Nt);
    boldUp = interpn(bold, xgrid, ygrid, zgrid, tgrid, 'pchip');
  end    
  
  % compute vaso
  dims = size(boldUp);  
  boldUp = reshape(boldUp, dims(1)*dims(2)*dims(3), dims(4));
  dims = size(nulledUp);  
  nulledUp = reshape(nulledUp, dims(1)*dims(2)*dims(3), dims(4));
  
  % loop over frames
  vaso = zeros(size(nulledUp));
  for iFrame = 1:dims(4);
    vaso(:,iFrame) = nulledUp(:,iFrame) ./ boldUp(:,iFrame);
  end
  
  % clip unrealistic values
  vaso(find(vaso<0)) = 0;
  vaso(isnan(vaso))  = 0;
  vaso(find(vaso>5)) = 5;
  
  vaso = reshape(vaso, dims(1), dims(2), dims(3), dims(4));
  boldUp = reshape(boldUp, dims(1), dims(2), dims(3), dims(4));

  % save
  scanParams = viewGet(v, 'scanparams', iScan);
  scanParams.fileName = [];
  scanParams.totalFrames = size(tSeries,4);

  % switch the the Vaso group
  scanParams.description = 'Vaso';
  v = viewSet(v, 'curGroup', 'Vaso');
  v = saveNewTSeries(v, vaso, scanParams, hdr);

  % switch the the Bold group
  scanParams.description = 'Bold';
  v = viewSet(v, 'curGroup', 'Bold');
  v = saveNewTSeries(v, boldUp, scanParams, hdr);
  
  saveSession();
end
deleteView(v);  


