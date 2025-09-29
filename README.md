# Reproducibility of grey matter differences in mental illness

Despite thousands of magnetic resonance imaging (MRI) studies reporting grey matter alterations in psychiatric disorders, the field has failed to converge on robust neuroanatomical phenotypes for any specific diagnosis. In this project, we examine whether current practices will ever converge on such a phenotype. We evaluated the consistency of brain-wide maps of grey matter volume and cortical thickness alterations obtained for each of the study sites of five psychiatric disorders (schizophrenia, schizoaffective disorder, autism spectrum disorder, major depressive disorder, and bipolar disorder). 

See "[Are neuroanatomical phenotypes for psychiatric disorders robust? An assessment of the reproducibility of grey matter differences in mental illness](https://medrxiv.org/cgi/content/short/2025.07.09.25331220v1)" for more details.

## File descriptions

In this package, we provide the codes that were used to obtain the results in the project. The main folders are:

  1. `data/`: sample data to run the pipeline.
  2. `utils/`: dependent packages and functions.
  3. `data_BIDS/`:  organising downloaded data into BIDS format and selecting subjects for the analysis.
  4. `SBM/`: analysing cortical thickness alteration maps using surface-based morphometry and evaluating their consistency.
  5. `VBM/`: analysing grey matter volume alteration maps using voxel-based morphometry and evaluating their consistency.

## Installation

1) Download/clone this repository.
2) Choose and edit a config file to match your environment:
   - `config_windows.json` (Windows)
   - `config_hpc.json` (HPC/cluster)
   - `config.json` (WSL/Linux example)
   Ensure `data_directories.dataset_root` points to the folder containing your datasets (e.g., `.../multiple_dataset`).
3) The pipeline accepts a config struct and internal scripts read relative to their own locations.

Read the comments in the config for details on paths, stages, and datasets.

## Data

Download two datasets [Myelin](https://openneuro.org/datasets/ds003653/versions/1.0.0) and [RD](https://openneuro.org/datasets/ds002748/versions/1.0.5) that are openly available from openneuro.org and put them in `data/` with folder name `Myelin` and `RD`, respectively. Please consult the link for detailed information about access, licensing, and terms and conditions of usage.

## Usage

### Run the pipeline from MATLAB

Open MATLAB in the repo root and run:

```matlab
run_pipeline('full',<config_file>);
```

This uses the configuration file to:
- Organize enabled datasets into BIDS
- Run VBM CAT12 preprocessing (step1)
- Continue with later VBM stages if enabled

You can also run specific stages, e.g.:

```matlab
run_pipeline('VBM_CAT12_step1a');
```

### Organising downloaded data into BIDS format

The pipeline calls `data_BIDS/BIDS_<Dataset>.m` for each enabled dataset in the config. These scripts read `dataset_root` from the config and write per-dataset `subject_use.txt` under `<dataset_root>/<Datas

#### step1 preprocessing (VBM/CAT12)
- The CAT12 step is launched by the pipeline via `VBM/preprocessing/step1_CAT12/step1a_CAT12_preprocessing_send.sh`.
- It reads the config, determines enabled datasets, writes the list to `<dataset_root>/dataset_list_VBM.txt`, and submits one job per subject.
- The environment variable `DATA_ROOT` is set automatically by the pipeline so downstream shell scripts can find your data.
- After CAT12 jobs have finished, the QC concatenation script `VBM/preprocessing/step1_CAT12/step1b_cat12_qcReport_concat.sh` is run to aggregate CAT12 QC values per dataset.
- The segmentation on native space and the normalisation on MRI space are concatinated for visualisation (quality control) by `step1c_visualisation.sh`. THIS HAS TO BE RUN DIRECTLY FROM BASH (as bash called from MATLAB doesn't provide visualisation-the function need to render a displayed image).

Manual usage (optional):
```bash
cd VBM/preprocessing/step1_CAT12

# To manually run, DATA_ROOT must be set:
sh ./step1a_CAT12_preprocessing_send.sh

# After CAT12 jobs have finished 
sh ./step1b_cat12_qcReport_concat.sh
sh ./step1c_visualisation.sh
```
#### step2

#### step3
## run glm model
run combine_metadata.m 
smooth maps by run run_smooth_TIV_send.sh
run make_mask.m (need to load VPM), one mask for all psychosis and one mask for AD. Threshold masking: At each voxel, if a value in any of the images falls below the threshold (0.2), then that voxel is excluded from the analysis.
.run glm_func.m from runGLM_batch.m by runGLM_send.sh, check runGLM_batch.m (use the same mask created for psychosis (or AD))


## Compatibility

The codes run on versions of MATLAB from R2023a to R2025a.

## Citation

If you use our code in your research, please cite us as follows:

Trang Cao, James C. Pang, Mehul Gajwani, Ashlea Segal, Alex Holmes,  Joshua Wiley, Sidhant Chopra,  Juan Helen Zhou, Christopher CH Chen, Fang Ji, Ben J Harrison, Christopher G Davey, Toby Constable, Jeggan Tiego, Bree Hartshorn, Jessica Kwee, Mark A. Bellgrove, Alex Fornito, Are neuroanatomical phenotypes for psychiatric disorders robust? An assessment of the reproducibility of grey matter differences in mental illness, (DOI: [2025.07.09.25331220](https://doi.org/10.1101/2025.07.09.25331220))

## Further details

Please contact trang.cao@monash.edu if you need any further details.










to run combat:
run combat_input.m  or run COMBATprepareInputs_sbatch.sh, check the list of dataset
run combat by COMBAT_run_sbatch_send.sh
run combat_output.m or run with slurm combat_output_send.sh
.run glm_combat_func.m from runGLM_batch.m by runGLM_send.sh

## run null by brainsmash
run matrix_volume.py(VBM)/matrix_midthickness.py(SBM) to make distance matrix
.run vol_dense_gen_send.sh
run binarize_tmap_brainsmash_null.m to get the binary maps
run corr_tmap_brainsmah_null_func.m by corr_tmap_brainsmah_null_send.sh
run corr_tmap_brainsmash_null_combine.m

## analysis
run corr_tmap.m
run figure_cor_tmap_raincloud.m


## covariate effect

## sample size effect


## for parcelation 
parcelate the template on CAT12MNI by roi/project_parcellations_on_CAT12MNI.sh
combine 3 template of cortex, subcortex, and cerebellum by roi/combine_parcellation.sh
run parcelation by roi/parcellate_maps_send.sh
run glm by roi/runGLM_parc_send.sh
run analysis/corr_tmap_parc.m
run roi/matToTxt.m and roi/matThresToTxt.m
run roi/parcellate_null_maps_send.sh to run parcellate_null_maps.m to parcellate nullmaps
run analysis/corr_tmap_parc_null.m

## plotting
figure_cor_tmap_raincloud.m -done
figure_cor_tmap_raincloud_combine_thres.m
figure_cor_tmap_raincloud_combine_smooth.m
figure_cor_tmap_raincloud_combine_smooth_thres.m

figure_cor_tmap_raincloud_combine_parc.m
figure_cor_tmap_raincloud_combine_combat_noncombat.m

# SBM
## preprocessing

if the dataset is longitudinal, run make_ses_list.sh to create a list of subject with the lowest session to use.

run check_output_recon.sh to create a list of subject for recon

run freesurfer/freesurfer_holmesQC/step0_recon_all for segmentation
run freesurfer/check_output_recon.sh
run freesurfer/check_MRIQC_output.sh
run freesurfer/freesurfer_holmesQC/step1_autoQC/Step1a.mriqc_individual.sh
run freesurfer/freesurfer_holmesQC/step1_autoQC/Step1b.mriqc_group.sh
run freesurfer/freesurfer_holmesQC/step1_autoQC/Step1c.euler.sh
run freesurfer/freesurfer_holmesQC/step1_autoQC/Step1d.mriqc_PCA.py in python for each dataset (PyCharm in Massive, config input and output in configuration Parameters for each dataset)
run part of extract_sub_<studyname>.m (upto write subWithoutOutlier	) to get the list of ouliners after QC.
run freesurfer/freesurfer_holmesQC/step2_surfacevis/Step2.fsleyes.sh

## run glm model
run part of extract_sub_surface_<studyname>.m to make qdec.dat
run combine_metadata.m 
run glm(replacing qdec) for each site by glmfit_send.sh, which run make_input_run_mri_glmfit.sh

to run combat:
run combat_surface_input.m 
run combat by COMBAT_run_sbatch_send.sh
run combat_surface_output.m 
run glm by glmfit_send.sh

## correlation
run corr_zmap.m

## parcel/traditional analysis
run parcelate_maps.m to parcelate to Schaefer
run glm_parc.m for glm
run corr_zmap_parc.m read all stat maps 

## eigentraping for null test (eigentrap the zmaps that are calculated without combat)
run nulltest.m by nulltest_send.sh
run parc_null.m to parcellate the null zmaps and thresholding the parcallated maps 
run ver_null.m to read the zmaps at vertice level 
run corr_zmap_parc_null.m to correlate parcelated null zmaps

run corr_zmap_null_func.m by corr_zmap_null_send.sh to calculate correlation for each null
run corr_zmap_null_combine.m to combine the correlations of all nulls 

## plotting results
figure_cor_zmap_raincloud.m
figure_cor_zmap_raincloud_combine_thres.m
figure_cor_zmap_raincloud_combine_smooth.m
figure_cor_zmap_raincloud_combine_smooth_thres.m

figure_cor_zmap_raincloud_combine_parc.m
figure_cor_zmap_raincloud_combine_combat_noncombat.m


## covariate effect
run corr_zmap_var_<var>.mlx (<var> sex, treatment,...)
run corr_zmap_covariate_combine.m to combine all the covariate effect
run figure_covariates.m


## sample size effect
run resample_2sitegroup_subdivide_samesize_send.sh to create same size subdivision
run glmfit_resample_2sitegroup_subdivide_samesize_send.sh for glmfit same size subdivision
run corr_map_subdivide_send.sh
run corr_zmap_subdivide_2sitegroup_samesize.m



run glmfit_resample_2sitegroup_job_aparc_send.sh (for DK parcelation from freesurfer pipeline)
run corr_map_subdivide_aparc_send.sh
run corr_zmap_subdivide_2sitegroup_samesize_aparc.m

run parc_resample_2sitegroup_subdivide_samesize_send to run parc_resample_2sitegroup.sh (for parcelation in DK and Scheafer from fsaverage.fwhm0 using matlab)
run glm_resample_2sitegroup_subdivide_samesize_send.sh to run glm_resample_2sitegroup.sh for glm
run corr_parc_resample_2sitegroup_subdivide_samesize_send for correlating each resample pair
run corr_zmap_parc_subdivide_2sitegroup_samesize.m
run figure_corr_zmap_subdivide_2sitegroup_samesize_combine.m
run figure_corr_zmap_subdivide_2sitegroup_samesize_combine_sub.m





