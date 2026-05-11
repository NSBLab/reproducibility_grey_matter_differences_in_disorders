function extract_sub_surface_Myelin(config)
% Extract subjects passing SBM QC and write qdec metadata for Myelin.
%
% Reads subjects_pass_visualisation.txt (created from
% subjects_pass_Euler_number_check.txt written by step2c.euler.sh, after
% removing subjects that fail visual surface inspection), looks up Euler
% numbers for the EN column, applies minimum subjects per diagnosis, and
% writes <study>_qdec_extended.csv.
%
% Trang Cao, Neural Systems and Behaviour Lab, Monash University, 2024.

study = 'Myelin';

if nargin < 1 || isempty(config)
    error('No config passed');
end

dataset_root  = config.data_directories.dataset_root;
study_path    = fullfile(dataset_root, study);
NSUB          = config.analysis_settings.minimum_subjects_per_site;

if ~isfield(config.datasets, study) || ~isfield(config.datasets.(study), 'path')
    error('Path not found in config for dataset %s', study);
end
source_path    = config.datasets.(study).path;
is_longitudinal = isfield(config.datasets.(study), 'longitudinal') && config.datasets.(study).longitudinal;

fprintf('=== EXTRACTING SURFACE SUBJECTS FOR %s ===\n', study);
fprintf('Longitudinal: %s\n', string(is_longitudinal));

% --- Euler numbers (for EN column in output) ---
holes_file = fullfile(source_path, 'derivatives', 'euler', sprintf('%s_holes.csv', study));
if ~exist(holes_file, 'file')
    error('Euler holes file not found: %s', holes_file);
end
holesFile = readtable(holes_file, 'ReadVariableNames', false);
if ~all(arrayfun(@(x) strcmp(holesFile.Var1{x}(1:end-3), holesFile.Var1{x+1}(1:end-3)), 1:2:length(holesFile.Var1)))
    error('Euler file does not have both hemispheres for each subject.');
end
inSubLh     = 1:2:length(holesFile.Var1);
eulerNumber = mean([2 - 2*holesFile.Var2(inSubLh), 2 - 2*holesFile.Var2(inSubLh+1)], 2);
subNames    = arrayfun(@(x) holesFile.Var1{inSubLh(x)}(1:end-3), 1:length(inSubLh), 'UniformOutput', false);

% subjects_pass_Euler_number_check.txt is written by step2c.euler.sh.
% subjects_pass_visualisation.txt is created from that file by manually
% removing subjects that fail visual surface inspection (step3).

% --- Subject list (after visual inspection) ---
fn = fullfile(study_path, 'subjects_pass_visualisation.txt');
if ~exist(fn, 'file')
    error('Missing %s — create from subjects_pass_Euler_number_check.txt after visual inspection', fn);
end
useFolder = readlines(fn);
useFolder = cellstr(useFolder(useFolder ~= ""));
fprintf('Subject list after visualisation: %d subjects\n', numel(useFolder));

% Look up EN for each visualisation-passed subject
[~, enIdx] = ismember(useFolder, subNames);
ENvalues   = nan(numel(useFolder), 1);
ENvalues(enIdx > 0) = eulerNumber(enIdx(enIdx > 0));

% --- Demographics ---
demographic_file = fullfile(source_path, 'participants.tsv');
if ~exist(demographic_file, 'file')
    error('Demographic file not found: %s', demographic_file);
end
imageFile = readtable(demographic_file, 'FileType', 'text', 'Delimiter', '\t');

% --- Build metadata ---
n = numel(useFolder);
metadata.subj_id     = useFolder;
metadata.dataset     = repmat({study}, n, 1);
metadata.site_string = metadata.dataset;
metadata.site        = repmat({'47'}, n, 1);
metadata.age         = zeros(n, 1);
metadata.sex_string  = cell(n, 1);
metadata.diag_raw    = cell(n, 1);

for i = 1:n
    row = find(strcmp(cellstr(imageFile.participant_id), useFolder{i}), 1);
    if ~isempty(row)
        metadata.age(i)        = imageFile.age(row);
        metadata.sex_string{i} = imageFile.sex{row};
        metadata.diag_raw{i}   = imageFile.group{row};
    else
        warning('Subject %s not found in demographic file', useFolder{i});
        metadata.age(i)        = NaN;
        metadata.sex_string{i} = 'Unknown';
        metadata.diag_raw{i}   = 'Unknown';
    end
end

metadata.sex = arrayfun(@(x) num2str(strcmp(x, 'M')), metadata.sex_string, 'UniformOutput', false);

[diag, ~, ~] = unique(imageFile.group);
control_idx  = find(strcmp(diag, 'HC'));
metadata.diagnosis_code = zeros(n, 1);
for i = 1:n
    di = find(strcmp(diag, metadata.diag_raw{i}));
    if ~isempty(di)
        if di == control_idx
            metadata.diagnosis_code(i) = 1;
        else
            metadata.diagnosis_code(i) = 6;
        end
    end
end
diagLabels = {'HC','BD','SCA','SCZ','ASD','MDD'};
metadata.diagnosis_string = arrayfun(@(x) diagLabels{x}, metadata.diagnosis_code, 'UniformOutput', false);
metadata.diagnosis        = arrayfun(@(x) num2str(x), metadata.diagnosis_code, 'UniformOutput', false);

% --- Minimum subjects per diagnosis ---
diagCat            = unique(metadata.diagnosis);
nSiteDiag          = cellfun(@(d) sum(strcmp(metadata.diagnosis, d)), diagCat);
nSiteDiagCondition = nSiteDiag >= NSUB;

metadata.con = false(n, 1);
for i = 1:n
    di = find(strcmp(diagCat, metadata.diagnosis{i}));
    if ~isempty(di) && nSiteDiagCondition(di)
        metadata.con(i) = true;
    end
end
fprintf('Final inclusion: %d subjects\n', sum(metadata.con));

% --- Write qdec table ---
metaTable = cell2table([...
    metadata.subj_id(metadata.con), metadata.dataset(metadata.con), ...
    metadata.site(metadata.con), metadata.diagnosis(metadata.con), ...
    cellstr(num2str(metadata.age(metadata.con))), ...
    metadata.sex(metadata.con), metadata.site_string(metadata.con), ...
    metadata.sex_string(metadata.con), metadata.diagnosis_string(metadata.con), ...
    arrayfun(@(x) num2str(x), ENvalues(metadata.con), 'UniformOutput', false)], ...
    'VariableNames', ["subj_id","dataset","site","diagnosis","age","sex","site_string","sex_string","diagnosis_string","EN"]);

out_file = fullfile(study_path, sprintf('%s_qdec_extended.csv', study));
writetable(metaTable, out_file);
fprintf('Saved: %s\n', out_file);
fprintf('=== DONE %s ===\n', study);
end
