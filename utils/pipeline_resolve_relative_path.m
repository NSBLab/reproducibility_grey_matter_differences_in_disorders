function absPath = pipeline_resolve_relative_path(baseDir, pathStr)
% If pathStr is absolute, return as-is; otherwise resolve relative to baseDir.
if nargin < 1 || isempty(baseDir)
    baseDir = pwd;
end
if ispc
    isAbs = ~isempty(regexp(pathStr, '^[A-Za-z]:\\|^\\\\', 'once'));
else
    isAbs = startsWith(pathStr, filesep);
end
if isAbs
    absPath = pathStr;
else
    absPath = fullfile(baseDir, pathStr);
end
end
