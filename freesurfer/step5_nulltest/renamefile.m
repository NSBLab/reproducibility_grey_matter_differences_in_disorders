% Directory path
datadir = '/scratch2/kg98/trangc/VBM/data/eigentrap';

datasets = dir(datadir);
datasets = datasets(~ismember({datasets.name}, {'.', '..'})); % Exclude '.' and '..'

for iSite = 1:length(datasets)
    files = dir(fullfile(datadir,datasets(iSite).name));
    files = files(~ismember({files.name}, {'.', '..'})); % Exclude '.' and '..'
% Loop through files
for i = 1:length(files)
    % Check for newline character in the file name
    if contains(files(i).name, newline)
        % Construct full file paths
        oldName = fullfile(files(i).folder, files(i).name);
        newName = strrep(files(i).name, newline, '10'); % Remove newline
        newPath = fullfile(files(i).folder, newName);
        
        % Rename the file
        try
            movefile(oldName, newPath);
            disp(['Renamed: ', files(i).name, ' -> ', newName]);
        catch ME
            disp(['Error renaming file: ', ME.message]);
        end
    end
end
end