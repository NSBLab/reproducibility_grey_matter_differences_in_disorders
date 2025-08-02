study = { 'BSNIP', 'BSNIP2','PARDIP'};
med=[];

for i=1:length(study)
medTable = readtable(['/projects/kg98/trangc/VBM/data/', study{i}, '/dem/meds01.txt']);
med = unique([med;medTable.medication1_name;medTable.medication2_name;medTable.medication3_name;medTable.medication4_name;medTable.medication5_name;medTable.medication6_name; medTable.medication7_name;medTable.medication8_name; medTable.medication9_name]);
end

study = { 'Modul_vent', 'Study_neura'};
for i=1:length(study)
medTable = readtable(['/projects/kg98/trangc/VBM/data/', study{i}, '/dem/medlist01.txt']);
med = unique([med;medTable.medication1_name;medTable.medication2_name;medTable.medication3_name;medTable.medication4_name;medTable.medication5_name]);
end

study = { 'ABIDEII'};
for i=1:length(study)
medTable = readtable(['/projects/kg98/trangc/VBM/data/', study{i}, '/dem/ABIDEII-BNI_1.csv']);
med = unique([med;medTable.CURRENT_MEDICATION_NAME]);
end

study = { 'UCLA'};
for i=1:length(study)
medTable = readtable(['/projects/kg98/trangc/VBM/data/', study{i}, '/dem/medication.csv']);
med = unique([med;medTable.med_name7;medTable.med_name5;medTable.med_name18;medTable.med_name14;...
    medTable.med_name17;medTable.med_name3;medTable.med_name1;medTable.med_name2;medTable.med_name16...
    ;medTable.med_name15;medTable.med_name4;medTable.med_name20;medTable.med_name19;medTable.med_name10;...
    medTable.med_name8;medTable.med_name13;medTable.med_name6;medTable.med_name12;medTable.med_name11;medTable.med_name9]);
end

% writetable(med,'/projects/kg98/trangc/VBM/data/medication_name.csv');