function repoRoot = pipeline_get_repo_root()
% Return absolute path to the repository root folder.
%
% Repo root is the parent of utils/ containing this helper.

thisDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(thisDir);
end
