clear all
map=readtable('/home/trangc/kg98/trangc/VBM/data/metadataSBM.csv');
 isDiagSite = (map.diagnosis==4);
 siteList= map.site(isDiagSite);
 subject = map.subj_id(ismember(map.site, siteList) & (map.diagnosis==4 | map.diagnosis==1));
 patient =  map.subj_id(ismember(map.site, siteList) & (map.diagnosis==4));
 control =  map.subj_id(ismember(map.site, siteList) & (map.diagnosis==1));