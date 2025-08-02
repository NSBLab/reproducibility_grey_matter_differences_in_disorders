import numpy as np
import pandas as pd
from scipy import stats
from sklearn import preprocessing
from sklearn import decomposition
import matplotlib.pyplot as plt

# Load in your data and specify threshold
data = pd.read_csv('/home/cche0120/kg98/Charlie/ABIDEI/ABIDEI_mriqc_group/group_T1w.tsv', sep='\t', index_col='bids_name')
threshold = 4
outdir = '/home/cche0120/kg98/Charlie/ABIDEI/ABIDEI_mriqc'

# mean centre and remove summary stats
data = data.drop(columns=['fwhm_x', 'fwhm_y', 'fwhm_z', 'inu_range', 'size_x', 'size_y', 'size_z', 'spacing_x', 'spacing_y', 'spacing_z', 'summary_bg_k', 'summary_bg_mad', 'summary_bg_mean', 'summary_bg_median', 'summary_bg_n', 'summary_bg_p05', 'summary_bg_p95', 'summary_bg_stdv', 'summary_csf_k', 'summary_csf_mad', 'summary_csf_mean', 'summary_csf_median', 'summary_csf_n', 'summary_csf_p05', 'summary_csf_p95', 'summary_csf_stdv', 'summary_gm_k', 'summary_gm_mad', 'summary_gm_mean', 'summary_gm_median', 'summary_gm_n', 'summary_gm_p05', 'summary_gm_p95', 'summary_gm_stdv', 'summary_wm_k', 'summary_wm_mad', 'summary_wm_mean', 'summary_wm_median', 'summary_wm_n', 'summary_wm_p05', 'summary_wm_p95', 'summary_wm_stdv'])
scaler = preprocessing.StandardScaler().fit(data)
data_mc = scaler.transform(data)
# Run PCA
#pca = decomposition.PCA(n_components=0.8, svd_solver='full')
pca = decomposition.PCA(svd_solver='full')
pca_out = pca.fit_transform(data_mc)
#print(pca.explained_variance_ratio_)
#print(pca_out)
# z-scores for outliers
pca_out = stats.zscore(pca_out)
# Visualise eigens and variance explained
plt.plot(np.cumsum(pca.explained_variance_ratio_))
plt.xlabel('number of components')
plt.ylabel('cumulative explained variance')
# pca.explained_variance_ratio_ contains the eigenvalues of the covariance matrix for each component
# Summing this provides the cumulative variance for all components up until the nth component
# e.g. the amount of variance of your original data that can be explained by using the first n components alone
# Add IDs to PCA
rows, cols = pca_out.shape
PC_labels = np.arange(cols)
PC_labels = [x+1 for x in PC_labels]
PC_labels = ['PC' + str(x) for x in PC_labels]
pca_out = pd.DataFrame(data=pca_out, index=data.index, columns=PC_labels)

#Remove outliers with z-score greater than threshold
outliers = pca_out[(pca_out[PC_labels] >= threshold) | (pca_out[PC_labels] <= threshold*-1)].dropna(how='all')
clean_subs = pca_out[(pca_out[PC_labels] < threshold) & (pca_out[PC_labels] > threshold*-1)].dropna(how='any')

# Save results
pca_out.to_csv('{}/MRIQC_PCA.csv'.format(outdir), encoding='utf-8-sig')
pd.Series(outliers.index).to_csv('{}/outlier_list.txt'.format(outdir), header=False, index=False, encoding='utf-8-sig')
pd.Series(clean_subs.index).to_csv('{}/clean_subs.txt'.format(outdir), header=False, index=False, encoding='utf-8-sig')

