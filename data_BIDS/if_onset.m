function [onset, illDuration]= if_onset(matchIDHighQRcon, hisFile, interviewAge, criteria )
if isnumeric(hisFile.src_subject_id)
[La indexIDinMed] = ismember(matchIDHighQRcon, cellstr(num2str(hisFile.src_subject_id))); % index in medFile 

else
    [La indexIDinMed] = ismember(matchIDHighQRcon, cellstr((hisFile.src_subject_id))); % index in medFile 

end
positiveIn = find(indexIDinMed>0);

columnNames = hisFile.Properties.VariableNames;
onsetIn = find(matches(columnNames, criteria)==1);

onset = nan(size(matchIDHighQRcon));

onset(positiveIn,1) = hisFile{indexIDinMed(positiveIn),onsetIn};

illDuration= interviewAge - onset;

 end