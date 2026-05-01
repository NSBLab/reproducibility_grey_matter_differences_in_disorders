function pipeline_ensure_paths()
% Ensure this repository's utils/ folder is on the MATLAB path.
%
% Calling this from standalone step scripts avoids requiring users to manually
% addpath(genpath(...)) before running helpers like pipeline_load_config.

thisDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(thisDir);
utilsDir = fullfile(repoRoot, 'utils');

persistent added
if isempty(added)
    addpath(utilsDir);
    added = true;
end
end
