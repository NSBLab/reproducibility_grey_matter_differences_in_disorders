# VBM
## BIDS
run BIDS_<studyname> to copy files into BIDS format

run first part of extract_sub_<studyname>.m (upto write useFolder) to get the list of subjects that can be used, i.e., adult (age 18-60) in a site that has at least 20HC and 20P.

## preprocessing
preprocessing/CAT12_preprocessing_send.sh for each dataset, require unzip file .nii

cat12_qcReport_concat.sh to combine CAT12 reports
extract_sub_<dataset>.m to get demo info

## run glm model
combine_metadata.m 
smooth maps by run run_smooth_TIV_send.sh
make_mask.m (need to load VPM), one mask for all psychosis and one mask for AD. Threshold masking: At each voxel, if a value in any of the images falls below the threshold (0.2), then that voxel is excluded from the analysis.
.glm_func.m from runGLM_batch.m by runGLM_send.sh, check runGLM_batch.m (use the same mask created for psychosis (or AD))-done 6 8 12mm

to run combat:
combat_input.m  or run COMBATprepareInputs_sbatch.sh, check the list of dataset -done 6 8 12
combat by COMBAT_run_sbatch_send.sh -done 6 8 12
combat_output.m or run with slurm combat_output_send.sh - done  6 8 12
glm_combat_func.m from runGLM_batch.m by runGLM_send.sh - done 8 6 12 

## run null by brainsmash
matrix_volume.py(VBM)/matrix_midthickness.py(SBM) to make distance matrix
vol_dense_gen_send.sh
binarize_tmap_brainsmash_null.m to get the binary maps
corr_tmap_brainsmah_null_func.m by corr_tmap_brainsmah_null_send.sh
corr_tmap_brainsmash_null_combine.m

## analysis
corr_tmap.m - done 6 8 12 combat and non
corr_tmap_per_study.m done

## covariate effect
corr_tmap_var_<var>.mlx (<var> sex, treatment,...)
corr_tmap_covariate_combine.m to combine all the covariate effect
plot_confound.m

## for parcelation 
parcelate the template on CAT12MNI by roi/project_parcellations_on_CAT12MNI.sh
combine 3 template of cortex, subcortex, and cerebellum by roi/combine_parcellation.sh
parcelation by roi/parcellate_maps_send.sh - done
glm by roi/runGLM_send.sh - done
analysis/corr_tmap_parc.m -done
####roi/matToTxt.m and roi/matThresToTxt.m
roi/parcellate_null_maps_send.sh to run parcellate_null_maps.m to parcellate nullmaps
analysis/corr_tmap_parc_null.m

## plotting
figure_cor_tmap_raincloud.m -done
figure_cor_tmap_raincloud_combine_thres.m
figure_cor_tmap_raincloud_combine_smooth.m
figure_cor_tmap_raincloud_combine_smooth_thres.m

figure_cor_tmap_raincloud_combine_parc.m
figure_cor_tmap_raincloud_combine_combat_noncombat.m


# SBM
## preprocessing
(skip if already run VBM) run first part of extract_sub_<studyname>.m (upto write useFolder) to get the list of subjects that can be used, i.e., adult (age 18-60) in a site that has at least 20HC and 20P.

if the dataset is longitudinal, run make_ses_list.sh to create a list of subject with the lowest session to use.

check_output_recon.sh to create a list of subject for recon

freesurfer/freesurfer_holmesQC/step0_recon_all for segmentation
freesurfer/check_output_recon.sh
freesurfer/check_MRIQC_output.sh
freesurfer/freesurfer_holmesQC/step1_autoQC/Step1a.mriqc_individual.sh
freesurfer/freesurfer_holmesQC/step1_autoQC/Step1b.mriqc_group.sh
freesurfer/freesurfer_holmesQC/step1_autoQC/Step1c.euler.sh
freesurfer/freesurfer_holmesQC/step1_autoQC/Step1d.mriqc_PCA.py in python for each dataset (PyCharm in Massive, config input and output in configuration Parameters for each dataset)
part of extract_sub_<studyname>.m (upto write subWithoutOutlier	) to get the list of ouliners after QC.
freesurfer/freesurfer_holmesQC/step2_surfacevis/Step2.fsleyes.sh

## run glm model
run part of extract_sub_surface_<studyname>.m to make qdec.dat
combine_metadata.m 
glm(replacing qdec) for each site by glmfit_send.sh, which run make_input_run_mri_glmfit.sh - done 10 15 20

to run combat:
combat_surface_input.m -done  10 15 20 0lh and 10rh
combat by COMBAT_run_sbatch_send.sh - done 10 15 20  0lh and 10rh
combat_surface_output.m done 10 15 20  0lh and 10rh
glm by glmfit_send.sh done 10 15 20 10rh

## correlation
corr_zmap.m done
corr_zmap_per_study.m done

## parcel/traditional analysis
parcelate_maps.m to parcelate to Schaefer - done
glm_parc.m for glm - done
corr_zmap_parc.m read all stat maps done

## eigentraping for null test (eigentrap the zmaps that are calculated without combat)
precal_eigenmode.m
nulltest.m by nulltest_send.sh done
parc_null.m to parcellate the null zmaps and thresholding the parcallated maps 
ver_null.m to read the zmaps at vertice level done
corr_zmap_parc_null.m to correlate parcelated null zmaps

corr_zmap_null_func.m by corr_zmap_null_send.sh to calculate correlation for each null done
corr_zmap_null_combine.m to combine the correlations of all nulls done

## plotting results
figure_cor_zmap_raincloud.m
figure_cor_zmap_raincloud_combine_thres.m
figure_cor_zmap_raincloud_combine_smooth.m
figure_cor_zmap_raincloud_combine_smooth_thres.m

figure_cor_zmap_raincloud_combine_parc.m
figure_cor_zmap_raincloud_combine_combat_noncombat.m

## covariate effect
corr_zmap_var_<var>.mlx (<var> sex, treatment,...) done
corr_zmap_covariate_combine.m to combine all the covariate effect done
plot_confound.m done


## sample size effect
resample_2sitegroup_subdivide_samesize_send.sh to create same size subdivision - done
glmfit_resample_2sitegroup_subdivide_samesize_send.sh for glmfit same size subdivision - done
corr_map_subdivide_send.sh done
corr_zmap_subdivide_2sitegroup_samesize.m done
figure_corr_zmap_subdivide_2sitegroup_samesize_combine.m done

parc_resample_2sitegroup_subdivide_samesize_send to run parc_resample_2sitegroup.sh (for parcelation in DK and Scheafer from fsaverage.fwhm0 using matlab) done
glm_resample_2sitegroup_subdivide_samesize_send.sh to run glm_resample_2sitegroup.sh for glm parcellated maps  done
corr_parc_resample_2sitegroup_subdivide_samesize_send for correlating each resample pair done
corr_zmap_parc_subdivide_2sitegroup_samesize.m done
figure_corr_zmap_subdivide_2sitegroup_samesize_combine_sub.m





