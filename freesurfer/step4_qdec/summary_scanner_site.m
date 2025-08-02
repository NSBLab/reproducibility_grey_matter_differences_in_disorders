clear all
%% Step 1: Read the CSV file

metaSBM = readtable('/projects/kg98/trangc/VBM/data/metadataSBM.csv');
metaVBM = readtable('/projects/kg98/trangc/VBM/data/metadataVBM.csv');
siteSBM = readtable('/projects/kg98/trangc/VBM/data/diagnosis_site_counts_detailed_SBM.csv');
siteVBM = readtable('/projects/kg98/trangc/VBM/data/diagnosis_site_counts_detailed_VBM.csv');
scanner = readtable('/projects/kg98/trangc/VBM/data/scanner.csv');
siteVBM.Index = string(siteVBM.Index);
%% check if any site in VBM but not in SBM
[lia lob] = ismember(strcat(siteVBM.Diagnosis,siteVBM.Site),strcat(siteSBM.Diagnosis,siteSBM.Site));
all(lia==1)

%% make new scanner table
varName = {'Diagnosis','Site','SBM index', 'VBM index', 'Dataset', 'Field strength (T)', ...
    'Scanner brand', 'Scanner model', 'Voxel measures (mm)', 'Voxel volume (mm3)'};
% Define variable types, assuming all as 'string' for simplicity,
% adjust these types according to the expected data type for each variable.
varTypes = {'string', 'string', 'double', 'string', 'string', ...
            'double', 'string', 'string', 'string', 'double'};
scanTable = table('Size',[height(siteSBM) length(varName)],'VariableTypes', varTypes, 'VariableNames',varName);

scanTable.Diagnosis = siteSBM.Diagnosis;

scanTable.Site = siteSBM.Site;

scanTable{:,3} = siteSBM.Index;

[lia lob] = ismember(strcat(siteSBM.Diagnosis,siteSBM.Site),strcat(siteVBM.Diagnosis,siteVBM.Site));
scanTable(lia,4) = siteVBM(lob(lob>0),2);

scanTable{:,5} = siteSBM.Dataset;

[lia lob] = ismember(reverse_change_siteName(siteSBM.Site),scanner.site_string);
% lob = lob(lob>0);
scanTable(lia,6) = scanner(lob,6);
scanTable(lia,7) = scanner(lob,7);
scanTable(lia,8) = scanner(lob,8);
scanTable(lia,9) = scanner(lob,9);
scanTable(lia,10) = scanner(lob,10);
disp(scanTable)
%%
% Step 4: Write results to a CSV file
writetable(scanTable, '/projects/kg98/trangc/VBM/data/scanner_site_detailed.csv');

