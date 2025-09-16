clear all
close all
addpath('/home/trangc/kg98/trangc/library/Violinplot-Matlab-master')
addpath(' /fs04/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec')
iCOMBAT = 1;
smoothKernel = 8;
diagString = {'HC', 'BD', 'SCA',...
    'SCZ', 'ASD', 'MDD' };

if iCOMBAT == 1
    address = ['derivatives/s',num2str(smoothKernel),'COMBAT/'];
else
    address = ['derivatives/s',num2str(smoothKernel),'/'];
end

metadata = readtable(['/home/trangc/kg98/trangc/VBM/data/derivatives/s',num2str(smoothKernel),'COMBAT/metadata.csv']);
mask = logical(niftiread(['/home/trangc/kg98/trangc/VBM/data/derivatives/s',char(num2str(smoothKernel)),'COMBAT/mask_group_mean_bin.nii']));

% diagnosisString = unique(metadata.diagnosis);
% diagnosisString = diagnosisString(~ismember(diagnosisString,'HC'));
% nDiag = length(diagnosisString);



% colorVec = {[0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980],	[0.9290, 0.6940, 0.1250],  [0.4940, 0.1840, 0.5560],  [0.4660, 0.6740, 0.1880]};
% 
% fig = figure('Position', [200 200 600 400]);
% factor_x = 1.2;
% factor_y = 2.2;
% init_x = 0.1;
% init_y = 0.1;
% num_row = 1;
% num_col = 1;
% length_x = (0.95 - init_x)/(factor_x*(num_col-1) + 1);
% length_y = (0.95 - init_y)/(factor_y*(num_row-1) + 1);
% lineWidth = 2;
% 
% font_name = 'Arial';
% font_size = 10;
% fontsize_legend = 8;
% ax2 = axes('Position', [init_x, init_y length_x length_y]);
% hold on
%%

for iSite = 1:length(diagString)-1
[LaDiag LbDiag] = ismember(metadata.diagnosis,num2str((iSite+1)));
[siteString ia ic] = unique(metadata.site_string(LaDiag));
[siteString] = change_siteName(siteString);
[cor1{iSite}, cor2{iSite}, rowst1_without_zeros{iSite}, rowst2_without_zeros{iSite}] = cal_corr_tmap_thres(address, metadata, diagString(iSite+1), mask);

end

save('output/corr_tmap_thres.mat', 'cor1', 'cor2')