function enabled_datasets = pipeline_get_enabled_datasets(config)
% Return cell array of dataset names with enabled == true (field order preserved).

enabled_datasets = {};
if ~isfield(config, 'datasets') || isempty(fieldnames(config.datasets))
    return;
end

dataset_names = fieldnames(config.datasets);
for k = 1:numel(dataset_names)
    name_k = dataset_names{k};
    ds = config.datasets.(name_k);
    if isfield(ds, 'enabled') && logical(ds.enabled)
        enabled_datasets{end+1} = name_k; %#ok<AGROW>
    end
end
end
