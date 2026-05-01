function config = pipeline_load_config(config_file)
% Load pipeline JSON configuration and resolve ${dataset_root} placeholders.
%
% Optionally stores config_file path on config struct.

if nargin < 1 || isempty(config_file)
    config_file = 'config.json';
end

try
    config = jsondecode(fileread(config_file));
    config = pipeline_resolve_config_variables(config);
    config.config_file = config_file;
catch ME
    error('Failed to load config file %s: %s', config_file, ME.message);
end
end
