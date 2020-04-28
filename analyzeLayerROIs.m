% makeLayerROIs.m
%
%      usage: makeLayerROIs()
%         by: eli merriam
%       date: 01/14/20
%    purpose: 
%
function retval = analyzeLayerROIs(v, roiname)

% check arguments
if ~any(nargin == [2])
  help analyzeLayerROIs
  return
end


response = [];
depths = 1:11;
v = viewSet(v, 'curGroup', 'Averages');
v = loadAnalysis(v, 'corAnal');

for iScan = 3:4
  for iDepth = 1:length(depths)
    layerroi = sprintf('lStimLayers%02.0f', iDepth);
    rois = loadROITSeries(v, layerroi, iScan, 'Averages');
    % average over voxels at a particular depth
    tSeries = nanmean(rois.tSeries);
    % get the analysis parameters for coranal (add error checking)
    anal = viewGet(v, 'corAnal');
    params = anal.params;
    % compute the corAnal on the average time series at a particular depth
    [co, amp, ph, ptSeries] = computeCoranal(tSeries',params.ncycles(iScan),params.detrend{iScan},params.spatialnorm{iScan},params.trigonometricFunction{iScan});
    % store the results
    response(iScan,iDepth) = amp;
    viewSet(getMLRView, 'deleteroi', 1);
  end
end


%%
smartfig('layerPlot');

% subplot(2,2,1);
% plot(fliplr(depths), response(1,:), 'o-');
% set(gca, 'Xtick', [1 10], 'XtickLabel', {'WM', 'Pial'});
% ylabel('Amplitude');
% xlabel('Depth'); 
% title('BOLD: phase scramble vs blank');
% drawPublishAxis;
% legend('off');

% subplot(2,2,2);
% plot(fliplr(depths), response(2,:), 'o-');
% set(gca, 'Xtick', [1 10], 'XtickLabel', {'WM', 'Pial'});
% ylabel('Amplitude');
% xlabel('Depth'); 
% title('BOLD: texture vs phase scramble');
% drawPublishAxis;
% legend('off');

subplot(1,2,1);
plot(fliplr(depths), response(3,:), 'o-');
set(gca, 'Xtick', [1 11], 'XtickLabel', {'WM', 'Pial'});
ylabel('Amplitude');
xlabel('Depth'); 
title('VASO: phase scramble vs blank');
drawPublishAxis;
legend('off');

subplot(1,2,2);
plot(fliplr(depths), response(4,:), 'o-');
set(gca, 'Xtick', [1 11], 'XtickLabel', {'WM', 'Pial'});
ylabel('Amplitude');
xlabel('Depth'); 
title('VASO: texture vs phase scramble');
drawPublishAxis;
legend('off');





%legend([1,2,3,4]);


%%
keyboard


