function step8f_corr_tmap_parc_null(config)
if nargin < 1 || isempty(config)
    config = 'config_hpc.json';
end
this_dir = fileparts(mfilename('fullpath'));
repo_root = fullfile(this_dir, '..', '..', '..');
addpath(genpath(fullfile(repo_root, 'utils')));
if ischar(config) || isstring(config)
    config = pipeline_load_config(char(config));
end

iCOMBAT = config.analysis_settings.harmonize;
smoothKernel = config.analysis_settings.vbm_smoothing_kernel;
diagString = {'HC', 'BD', 'SCA', 'SCZ', 'ASD', 'MDD', 'AD'};
data_root = config.data_directories.dataset_root;
metadata = readtable(fullfile(data_root, 'metadataVBM.csv'));
if iCOMBAT == 1
    nulldir = fullfile(data_root, 'nulltest', 'surrogateVBM', ['s', num2str(smoothKernel), 'COMBAT']);
else
    nulldir = fullfile(data_root, 'nulltest', 'surrogateVBM', ['s', num2str(smoothKernel)]);
end
output_dir = fullfile(data_root, 'results', 'VBM', 'analysis', 'output');
if ~exist(output_dir, 'dir'); mkdir(output_dir); end
nParc = [100 500 1000];
nNull = 100;

corNull = cell(1,length(diagString)-1);

for iParc = 1:length(nParc)


    for iDiag = 1:length(diagString)-1

        [corNull{iDiag} corThresNull{iDiag} repThresNull{iDiag} siteList{iDiag}] = ...
            cal_corr_tmap_parcel_null(nulldir, metadata, diagString(iDiag+1), nParc(iParc), nNull);
       
    end

    save(fullfile(output_dir, ['corr_null_tmap_parc_', num2str(nParc(iParc)), '.mat']), ...
        'corNull', 'corThresNull', 'repThresNull', 'siteList')
    clear corNull corThresNull repThresNull siteList
end
end