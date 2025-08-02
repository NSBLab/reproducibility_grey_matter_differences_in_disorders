% Directory path
datadir = '/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec/output';

files = dir(fullfile(datadir,'zmap_null_COMBAT1_smooth10_ver_part_*'));
files = files(~ismember({files.name}, {'.', '..'})); % Exclude '.' and '..'

for i = 1:length(files)


        % Construct full file paths
        oldName = fullfile(files(i).folder, files(i).name);
        newName = strrep(oldName, 'COMBAT1_smooth', 'COMBAT1_lh_smooth');  % New filename
       
        
        % Rename the file
        try
            movefile(oldName, newName);
            disp(['Renamed: ', files(i).name, ' -> ', newName]);
        catch ME
            disp(['Error renaming file: ', ME.message]);
        end
    

end