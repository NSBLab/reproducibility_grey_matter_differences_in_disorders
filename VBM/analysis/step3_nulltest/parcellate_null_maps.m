% parcellate subject maps
function parcellate_null_maps(diagnosisString,site,nulldir,nNull)
dataDir = fullfile('/projects','kg98','trangc','VBM','data');

cereInfo = niftiinfo('/home/trangc/kg98/trangc/atlases/Human_cerebellum/Buckner-whole_1mm_CAT12MNI.nii.gz'); %same info as the combine parcelation

nParcList = [100 500 1000];

filename = '/projects/kg98/trangc/VBM/data/metadataVBM.csv'  % Change this to the path of your CSV file
metadata = readtable(filename);


        % loop through all surrogated maps
        for iNull = 1:nNull
            
            nullfile = fullfile(nulldir, diagnosisString,site,['spmT_0001_surrogate_',char(num2str(iNull)),'.nii.gz'])
            if exist(nullfile)
                %read map
                map = spm_vol(nullfile);
                
                
                
                
                for iParc = 1:length(nParcList)
                    % read the thresholded maps
                    roiStruct = load(fullfile(dataDir,'derivatives','roi',diagnosisString,site,[num2str(nParcList(iParc)),'_parcCon.mat']),'stat');
                    binMap = roiStruct.stat.thresMap;
                    nBin = sum(binMap);
                    
                    parc = niftiread(['Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_',num2str(nParcList(iParc)),'Parcels_7Networks_order_CAT12MNI.nii']);
                    volParc = get_vol_parc(map, parc);
                    
                    % Find indices of the N largest values in tmap
                    [~, idx_sorted] = sort( volParc, 'descend');
                    top_indices_bin = idx_sorted(1:nBin);
                    
                    % Set the top N points to 1
                    binParc = zeros(size(binMap));
                    binParc(top_indices_bin) = 1;
                    
                    save(fullfile(nulldir, diagnosisString,site,['spmT_0001_surrogate_',char(num2str(iNull)),'_T1w_Buckner-whole_1mm_Tian_Subcortex_S1_3T_2009cAsym_Schaefer2018_',char(num2str(nParcList(iParc))),'Parcels_7Networks_order_CAT12MNI.mat']),'volParc','binParc');
               
                end
            end
            
        end
    end
    


