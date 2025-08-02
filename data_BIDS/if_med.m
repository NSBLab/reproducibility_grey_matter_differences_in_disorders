function med = if_med(matchIDHighQRcon, medFile, medName, drugType, maxNoMed,varargin)

if ismember(varargin, 'UCLA')

        [La indexIDinMed] = ismember(matchIDHighQRcon, medFile.participant_id); % index in medFile
        positiveIn = find(indexIDinMed>0);

        columnNames = medFile.Properties.VariableNames;
        colIn = find(matches(columnNames,'med_name'+wildcardPattern)==1);
elseif ismember(varargin,  'PARDIP')
        [La indexIDinMed] = ismember(matchIDHighQRcon, cellstr(num2str(medFile.src_subject_id))); % index in medFile

        positiveIn = find(indexIDinMed>0);

        columnNames = medFile.Properties.VariableNames;
        colIn = find(matches(columnNames,'medication'+wildcardPattern+'_name')==1);
    elseif ismember(varargin, 'Determinant')

        [La indexIDinMed] = ismember(matchIDHighQRcon, cellstr(num2str(medFile.src_subject_id))); % index in medFile
        %[La indexIDinMed] = ismember(matchIDHighQRcon, char(num2str(medFile.src_subject_id)));
        positiveIn = find(indexIDinMed>0);

        columnNames = medFile.Properties.VariableNames;
        colIn = find(matches(columnNames,'mr_antipsych'+wildcardPattern)==1 | ...
            matches(columnNames,'medication'+wildcardPattern+'_name')==1 | ...
            matches(columnNames,'antipsych'+digitsPattern)==1);

    elseif ismember(varargin, 'MBBP')
        [La indexIDinMed] = ismember(matchIDHighQRcon, medFile.record_id); % index in medFile

        positiveIn = find(indexIDinMed>0);

        columnNames = medFile.Properties.VariableNames;
        colIn = find(matches(columnNames,'medication'+digitsPattern)==1);

    else
        [La indexIDinMed] = ismember(extract(matchIDHighQRcon,digitsPattern), cellstr((extract(medFile.src_subject_id,digitsPattern)))); % index in medFile
        %[La indexIDinMed] = ismember(matchIDHighQRcon, char(num2str(medFile.src_subject_id)));
        positiveIn = find(indexIDinMed>0);

        columnNames = medFile.Properties.VariableNames;
        colIn = find(matches(columnNames,'medication'+wildcardPattern+'_name')==1);
end
maxNoMed = min(maxNoMed,length(colIn));
[La indexMed1inName] = ismember(cellstr(lower(medFile{indexIDinMed(positiveIn),colIn(1)})),cellstr(medName.Name));
indexMed1inName(indexMed1inName==0)=length(medName.Name); % unknown drug treated as nonclassified
temp = logical(medName{indexMed1inName,drugType});

for i = 2:maxNoMed
    [La indexMed2inName] = ismember(cellstr(lower(medFile{indexIDinMed(positiveIn),colIn(i)})),cellstr(medName.Name));
    indexMed2inName(indexMed2inName==0)=length(medName.Name); % unknown drug treated as nonclassified
    temp = temp | logical(medName{indexMed2inName,drugType});
end

med(positiveIn,1) = temp;

end