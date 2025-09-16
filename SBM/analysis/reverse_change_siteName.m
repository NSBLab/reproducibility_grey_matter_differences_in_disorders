function [siteAbbreviation] = reverse_change_siteName(siteFullName)
%REVERSE_CHANGE_SITENAME Change full meaningful name back to site abbreviation.
%   Input: cell array of full names
%   Output: cell array of abbreviated names

% Initialize output cell array
siteAbbreviation = siteFullName;

% Iterate through each site full name
for i = 1:length(siteFullName)
    % Convert to char for switch-case compatibility
    currentName = char(siteFullName{i});
    
    % Determine the abbreviation based on the full site name
    switch currentName
        case 'MCIC-A', siteAbbreviation{i} = 'A';
        case 'MCIC-C', siteAbbreviation{i} = 'C';
        case 'MCIC-D', siteAbbreviation{i} = 'D';
        case 'ALNA', siteAbbreviation{i} = 'Atypical';
        case 'AIS', siteAbbreviation{i} = 'Advan_inno';
        case 'HCP-EP', siteAbbreviation{i} = 'HCP';
        case 'IDAUT', siteAbbreviation{i} = 'Inhi_dys';
        case 'MRITDCS', siteAbbreviation{i} = 'Modul_vent';
        case 'PARDIP1', siteAbbreviation{i} = 'Philips';
        case 'PARDIP2', siteAbbreviation{i} = 'Signa_HDxt';
        case 'EMOSCZ', siteAbbreviation{i} = 'Study_neura';
        case 'Boston1', siteAbbreviation{i} = 'boston';
        case 'Boston2', siteAbbreviation{i} = 'Boston';
        case 'Chicago', siteAbbreviation{i} = 'chicago';
        case 'Dallas1', siteAbbreviation{i} = 'dallas';
        case 'Dallas2', siteAbbreviation{i} = 'Dallas';
        case 'Georgia', siteAbbreviation{i} = 'georgia';
        case 'Hartford1', siteAbbreviation{i} = 'hartford';
        case 'Hartford2', siteAbbreviation{i} = 'Hartford';
        case 'Speech', siteAbbreviation{i} = 'speech';
        case 'MIRIAD', siteAbbreviation{i} = 'miriad';
        case 'DSD', siteAbbreviation{i} = 'Determinant';
        case 'MICCD', siteAbbreviation{i} = 'MultidimCog';
        case 'SHSCBV', siteAbbreviation{i} = 'Specificity';
        case 'RD', siteAbbreviation{i} = 'RestDepress';
        case 'TCP', siteAbbreviation{i} = 'Transdiagnostic';
        case 'ASD45', siteAbbreviation{i} = 'Brain45';
            case 'YoDA', siteAbbreviation{i} = 'YMDD';
        otherwise
            % Handle unknown full names
            warning('Unknown full name: %s', currentName);
    end
end
end
