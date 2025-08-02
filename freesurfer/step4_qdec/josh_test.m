function R = josh_test(Nregions, Nsites, Npeople, PropImpacted, weights)

% Unpack weights
w_signal = weights(1);
w_site_region = weights(2);
w_person_region = weights(3);
w_site_group_region = weights(4);
w_site_person_region = weights(5);

% Create ID tables
Regions = (1:Nregions)';
Sites = (1:Nsites)';
Groups = {'Case', 'Control'};
People = (1:Npeople)';

% Determine impacted regions
rng(1234);
impacted_idx = randsample(Nregions, round(Nregions * PropImpacted));
is_impacted = ismember(Regions, impacted_idx);

% Preallocate measured matrix
% Dim: Subject × Region
data = table;
subject_id = 1;

for s = 1:Nsites
    for g = 1:2 % 1=Case, 2=Control
        group_label = Groups{g};
        for p = 1:Npeople
            person_id = sprintf('S%02d_G%d_P%03d', s, g, p);

            for r = 1:Nregions
                % Base region value
                base = randn(1);

                % Signal
                signal = 0;
                if strcmp(group_label, 'Case') && is_impacted(r)
                    % Flip signs for some to vary
                    sign_flip = 1 - 2 * mod(r,2); % alternate -1 and 1
                    signal = randn(1) * 0.5 + sign_flip * 0.5;
                end

                % Noise terms
                noise_site_region = randn(1);
                noise_person_region = randn(1);
                noise_site_group_region = randn(1);
                noise_site_person_region = randn(1);

                % Total measured signal
                measured = base + ...
                    w_signal * signal + ...
                    w_site_region * noise_site_region + ...
                    w_person_region * noise_person_region + ...
                    w_site_group_region * noise_site_group_region + ...
                    w_site_person_region * noise_site_person_region;

                % Store
                data = [data; {
                    s, group_label, person_id, r, measured
                }];
            end
        end
    end
end

data = cell2table(data, ...
    'VariableNames', {'Site', 'Group', 'Person', 'Region', 'Measured'});

% Average over people within Site × Group × Region
avgData = varfun(@mean, data, ...
    'InputVariables', 'Measured', ...
    'GroupingVariables', {'Site', 'Group', 'Region'});

% Pivot to wide format: Case vs Control
pivoted = unstack(avgData, 'mean_Measured', 'Group');
pivoted.Diff = pivoted.Case - pivoted.Control;

% Now reshape to Region × Site format
allSites = unique(pivoted.Site);
DiffMat = NaN(Nregions, Nsites);

for i = 1:height(pivoted)
    r = pivoted.Region(i);
    s = pivoted.Site(i);
    DiffMat(r, s) = pivoted.Diff(i);
end

% Compute correlation between columns (sites)
R = corr(DiffMat', 'rows', 'pairwise');

end
