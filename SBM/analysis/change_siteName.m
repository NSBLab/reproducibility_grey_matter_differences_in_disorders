function [siteName] = change_siteName(siteString)
% change site name to meaningful name
% input: cell array of name
% output: cell array of name changed

siteName = siteString;
for i = 1:length(siteString)
    switch char(siteString(i))
        case 'A'
            siteName(i) = cellstr('MCIC-A');
        case 'C'
            siteName(i) = cellstr('MCIC-C');
        case 'D'
            siteName(i) = cellstr('MCIC-D');
        case 'Atypical'
            siteName(i) = cellstr('ALNA');
        case 'Advan_inno'
            siteName(i) = cellstr('AIS');
        case 'HCP'
            siteName(i) = cellstr('HCP-EP');
        case 'Inhi_dys'
            siteName(i) = cellstr('IDAUT');
        case 'Modul_vent'
            siteName(i) = cellstr('MRITDCS');
        case 'Philips'
            siteName(i) = cellstr('PARDIP1');
        case 'Signa_HDxt'
            siteName(i) = cellstr('PARDIP2');
        case 'Study_neura'
            siteName(i) = cellstr('EMOSCZ');
        case 'boston'
            siteName(i) = cellstr('Boston1');
        case 'Boston'
            siteName(i) = cellstr('Boston2');
        case 'chicago'
            siteName(i) = cellstr('Chicago');
        case 'dallas'
            siteName(i) = cellstr('Dallas1');
        case 'Dallas'
            siteName(i) = cellstr('Dallas2');
        case 'georgia'
            siteName(i) = cellstr('Georgia');
        case 'hartford'
            siteName(i) = cellstr('Hartford1');
        case 'Hartford'
            siteName(i) = cellstr('Hartford2');
        case 'speech'
            siteName(i) = cellstr('Speech');
        case 'miriad'
            siteName(i) = cellstr('MIRIAD');
        case 'Determinant'
            siteName(i) = cellstr('DSD');
        case 'MultidimCog'
            siteName(i) = cellstr('MICCD');
        case 'Specificity'
            siteName(i) = cellstr('SHSCBV');
        case 'RestDepress'
            siteName(i) = cellstr('RD');
        case 'Transdiagnostic'
            siteName(i) = cellstr('TCP');
        case 'Brain45'
            siteName(i) = cellstr('ASD45');
            case 'YMDD'
            siteName(i) = cellstr('YoDA');
            
    end
end
