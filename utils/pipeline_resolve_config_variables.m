function config = pipeline_resolve_config_variables(config)
% Resolve ${dataset_root} references in dataset paths (same semantics as run_pipeline.m).

if isfield(config, 'data_directories') && isfield(config.data_directories, 'dataset_root')
    dataset_root = config.data_directories.dataset_root;
    if isfield(config, 'datasets')
        dataset_names = fieldnames(config.datasets);
        for i = 1:numel(dataset_names)
            dataset_name = dataset_names{i};
            if isfield(config.datasets.(dataset_name), 'path')
                path = config.datasets.(dataset_name).path;
                config.datasets.(dataset_name).path = strrep(path, '${dataset_root}', dataset_root);
            end
        end
    end
end
end
