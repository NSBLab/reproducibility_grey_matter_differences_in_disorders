function modify_fsgd_site(dataDir, dataset, site)

site

copyfile(fullfile(dataDir, dataset, 'derivatives','freesurfer','qdec',site, 'qdec.fsgd'),...
    fullfile(dataDir, dataset, 'derivatives','freesurfer','qdec',site, 'qdec_bk.fsgd'));


oriFsgd = readlines(fullfile(dataDir, dataset, 'derivatives','freesurfer','qdec',site, 'qdec.fsgd'));
for iLine = 7:length(oriFsgd)-1
    C = strsplit(oriFsgd(iLine), ' ');
    idList(iLine) = C(2);
end

mark = readlines(fullfile(dataDir, dataset, 'sub_without_outlier_marked.txt'));

iDel = 1;
Del = [];
for iMark = 1:length(mark)-1
    splitMark = strsplit(mark(iMark), '\t');
    if length(splitMark) == 3
    [Lia Locb] = ismember(splitMark(2),idList);
    if strcmp(splitMark(3),'x') & Lia==1
        Del(iDel) = Locb ;
        iDel = iDel +1;
    end
    end
end

oriFsgd(Del) = [];

writematrix(oriFsgd,fullfile(dataDir, dataset, 'derivatives','freesurfer','qdec',site, 'qdec.txt'));
copyfile(fullfile(dataDir, dataset, 'derivatives','freesurfer','qdec',site, 'qdec.txt'),...
    fullfile(dataDir, dataset, 'derivatives','freesurfer','qdec',site, 'qdec.fsgd'));
end

