function findClosestFolders(baseDir,  resultsFile)
    % baseDir: The directory to search for folders.
    % targetValues: Array of target values (e.g., [0.1, 0.2, ...]).
    % resultsFile: File to save results.

 targetValues = 0.1:0.1:1;
 
    % Find all folders matching the pattern
    folderPattern = fullfile(baseDir, 'iSubdivide_*_seed2group_*');
    folders = dir(folderPattern);
    
    % Initialize storage for closest matches
    closestFolders = cell(size(targetValues));
    closestDiffs = inf(size(targetValues));

    % Loop through each folder
    for i = 1:length(folders)
        folderPath = fullfile(folders(i).folder, folders(i).name);
        matFilePath = fullfile(folderPath, 'corr_surface.mat');

        % Skip if corr_surface.mat is missing
        if ~isfile(matFilePath)
            fprintf('Missing file in %s\n', folderPath);
            continue;
        end

        % Load corDiag value
        try
            data = load(matFilePath, 'corDiag');
            corDiag = data.corDiag; % Assume it's a scalar
        catch
            fprintf('Error loading corDiag in %s\n', folderPath);
            continue;
        end

        % Compare corDiag to each target value
        for t = 1:length(targetValues)
            diff = abs(corDiag - targetValues(t));
            if diff < closestDiffs(t)
                closestDiffs(t) = diff;
                corVa(t) = corDiag;
                closestFolders{t} = folders(i).name;
            end
        end
    end

    % Save results to the results file
    fid = fopen(resultsFile, 'w');
   
    for t = 1:length(targetValues)-1
        if corVa(t+1)-corVa(t)>0.05
        fprintf(fid, '%.2f\t%s\n', ...
                targetValues(t), closestFolders{t});
        % fprintf(fid, 'Target: %.2f, Closest Folder: %s, Difference: %.4f, Corr: %.4f\n', ...
        %         targetValues(t), closestFolders{t}, closestDiffs(t), corVa(t));
        tmax = t;
        end
    end
    fprintf(fid, '%.2f\t%s\n', ...
                targetValues(tmax+1), closestFolders{tmax+1});
    fclose(fid);
end
