% check surrogate map
% mask=niftiread(['/projects/kg98/trangc/VBM/data/derivatives/s6COMBAT/mask_AD/mask.nii']);
% 
% map=niftiread('/home/trangc/kg98/trangc/VBM/data/derivatives/s6COMBAT/AD/AIBL-2/spmT_0001.nii');
mask=niftiread(['/projects/kg98/trangc/VBM/data/derivatives/s6COMBAT/mask_psy/mask_lh.nii']);
% parnifti = niftiread('/fs03/kg98/gchan/Atlases/Tian/Schaefer_Tian/reordered/Schaefer2018_100Parcels_7Networks_order_Tian_Subcortex_S2_MNI152NLin6Asym_1.5mm_reordered.nii.gz');
% roi_i = 51;
% roi_j = 66;
%  mask = double((parnifti >= roi_i) & (parnifti <= roi_j));
surGB=readmatrix('/home/trangc/kg98_scratch/gchan/untitled folder/surrogate_maps.csv');
mask=readmatrix('/home/trangc/kg98_scratch/gchan/untitled folder/mask.csv');

map=niftiread('/home/trangc/kg98/trangc/VBM/data/derivatives/s6COMBAT/BD/Baltimore/spmT_0001.nii');
makemap=map(mask>0);
% plot t-map
orimap=mask;
orimap(mask>0)=makemap;
brainSliceori = (squeeze(orimap(:,:,55)))';
smoothKernel = 6;

figure;
z = zeros(size(brainSliceori)); % Flat surface (Z = 0 everywhere)
[x, y] = meshgrid(1:size(brainSliceori, 2), 1:size(brainSliceori,1));
ax3=gca
surf(ax3,x, y,z, brainSliceori, 'EdgeColor', 'none'); % No edges for smooth visualization
view(2)
daspect([1 1 1]); % Equal spacing for X, Y, and Z

%% plot surrogate map 1
figure
valList =  1000:1000:2000; %1500:500:2100;
nVal = length(valList);
nRow = 1;
nCol = ceil(nVal/nRow);
for iVal = 1:nVal
    ns = 500;
    knn = valList(iVal);
    pv = 70;
file1 = (['/home/trangc/kg98/trangc/VBM/code/nulltest/pythonProject/test_dense_vol_map',char(num2str(ns)),'_',char(num2str(knn)),'_',char(num2str(pv)),'_index_lh.txt']);
% file1 = (['/home/trangc/kg98/trangc/VBM/code/nulltest/pythonProject/test_dense_vol_map',char(num2str(ns)),'_',char(num2str(knn)),'_',char(num2str(pv)),'_smooth',char(num2str(smoothKernel)),'_GB.txt']);
% Construct the file path for the surrogate map of the current site.
surrogateMap10 = dlmread(file1);
surrogateMap11 = reshape(surrogateMap10,[],2);
surrogateMap1 = surrogateMap11(:,1);


surmap=mask;
surmap(mask>0)=surrogateMap1(:,1);

brainSliceori = (squeeze(surmap(:,:,40)))';


subplot(nRow,nCol, iVal);
z = zeros(size(brainSliceori)); % Flat surface (Z = 0 everywhere)
[x, y] = meshgrid(1:size(brainSliceori, 2), 1:size(brainSliceori,1));
ax3=gca
surf(ax3,x, y,z, brainSliceori, 'EdgeColor', 'none'); % No edges for smooth visualization
view(2)
daspect([1 1 1]); % Equal spacing for X, Y, and Z
colormap(ax3,bluewhitered(ax3))
title(['ns =',char(num2str(ns)),', knn =',char(num2str(knn)),', pv =',char(num2str(pv))])
% % plot surrogate map 2
% surmap2=mask;
% surmap2(mask>0)=surrogateMap2(:,1);
% brainSliceori2 = (squeeze(surmap2(:,:,55)))';
% 
% figure;
% z = zeros(size(brainSliceori2)); % Flat surface (Z = 0 everywhere)
% [x, y] = meshgrid(1:size(brainSliceori2, 2), 1:size(brainSliceori2,1));
% ax3=gca
% surf(ax3,x, y,z, brainSliceori2, 'EdgeColor', 'none'); % No edges for smooth visualization
% view(2)
% daspect([1 1 1]); % Equal spacing for X, Y, and Z
end
%% variogram
figure
for iVal = 1:nVal
    ns = 500;
    knn = valList(iVal);
    pv = 70;
empvar=readmatrix(['/home/trangc/kg98/trangc/VBM/code/nulltest/pythonProject/test_dense_vol_emp_vario',char(num2str(ns)),'_',char(num2str(knn)),'_',char(num2str(pv)),'_smooth6_index.txt']);
survar=readmatrix(['/home/trangc/kg98/trangc/VBM/code/nulltest/pythonProject/test_dense_vol_sur_vario',char(num2str(ns)),'_',char(num2str(knn)),'_',char(num2str(pv)),'_smooth6_index.txt']);
subplot(nRow,nCol, iVal);
hold on
plot(1:25,empvar,'o')
plot( 1:25, survar,'-')
title(['ns =',char(num2str(ns)),', knn =',char(num2str(knn)),', pv =',char(num2str(pv))])
xlabel('distances')
ylabel('variance')
end
