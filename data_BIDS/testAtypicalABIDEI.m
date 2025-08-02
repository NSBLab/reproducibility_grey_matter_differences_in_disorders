%check atypical and ABIDEI
clear all
atyList = readlines(['/projects/kg98/trangc/VBM/data/Atypical/subject_use.txt']);

mkdir('temp1');
mkdir('temp2');

ABIList = readlines(['/projects/kg98/trangc/VBM/data/ABIDEI/subject_use.txt']);

for i=1:length(atyList)
    copyfile(['/projects/kg98/trangc/VBM/data/Atypical/',char(atyList(i)),'/anat/',char(atyList(i)),'_T1w.nii'],...
        ['temp1/',char(atyList(i)),'_T1w.nii']);
end

for i=1:length(ABIList)
    if exist(['/projects/kg98/trangc/VBM/data/ABIDEI/',char(ABIList(i)),'/anat/',char(ABIList(i)),'_T1w.nii'])
    copyfile(['/projects/kg98/trangc/VBM/data/ABIDEI/',char(ABIList(i)),'/anat/',char(ABIList(i)),'_T1w.nii'],...
        ['temp2/',char(ABIList(i)),'_T1w.nii']);
    end
end

listAty= dir('temp1');
listABI = dir('temp2');