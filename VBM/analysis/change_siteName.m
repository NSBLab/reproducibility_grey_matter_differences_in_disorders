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
        case 'Atypical'
             siteName(i) = cellstr('ALNA');
        case 'Advan_inno'
            siteName(i) = cellstr('AGMND');
        case 'Inhi_dys'
            siteName(i) = cellstr('IDA');
        case 'Modul_vent'
             siteName(i) = cellstr('MVPCA');
        case 'Philips'
            siteName(i) = cellstr('PARDIP');
        case 'Study_neura'
            siteName(i) = cellstr('EMPD');
        case 'boston'
            siteName(i) = cellstr('Boston');
        case 'chicago'
             siteName(i) = cellstr('Chicago');
        case 'dallas'
            siteName(i) = cellstr('Dallas2');
        case 'Dallas'
            siteName(i) = cellstr('Dallas1');
        case 'georgia'
            siteName(i) = cellstr('Georgia');
        case 'hartford'
             siteName(i) = cellstr('Hartford');
             case 'speech'
             siteName(i) = cellstr('SPAH');
    end
end
