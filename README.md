# The cross-site reproducibility of MRI morphometric phenotypes in psychiatric disorders

Despite thousands of magnetic resonance imaging (MRI) studies reporting grey matter alterations in psychiatric disorders, the field has failed to converge on robust neuroanatomical phenotypes for any specific diagnosis. In this project, we examine whether current practices will ever converge on such a phenotype. We evaluated the consistency of brain-wide maps of grey matter volume and cortical thickness alterations obtained for each of the study sites of five psychiatric disorders (schizophrenia, schizoaffective disorder, autism spectrum disorder, major depressive disorder, and bipolar disorder). 

See "[The cross-site reproducibility of MRI morphometric phenotypes in psychiatric disorders](https://www.medrxiv.org/content/10.1101/2025.07.09.25331220v2)" for more details.

## Repository layout

In this package, we provide the codes that were used to obtain the results in the project. The main folders are:
  1. `data/`: sample data to run the pipeline.
  2. `utils/`: dependent packages and functions, including [modes](https://github.com/magnesium2400/nihelp.git)
  3. `data_BIDS/`:  organising downloaded data into BIDS format and selecting subjects for the analysis.
  4. `SBM/`: analysing cortical thickness alteration maps using surface-based morphometry (SBM) and evaluating their 
  consistency.
  5. `VBM/`: analysing grey matter volume alteration maps using voxel-based morphometry (VBM) and evaluating their consistency.
  
Root JSON configs (e.g. `config_hpc.json`, `config_windows.json`, `config_linux.json`) define `data_directories.dataset_root`, enabled datasets, and analysis/HPC settings. Bash steps read the config with `jq` (install `jq` on the login/compute environment used for those scripts).

## Installation

1. Clone this repository.
2. Copy or edit a config file so `data_directories.dataset_root` points at the parent folder of your dataset directories (each dataset is `${dataset_root}/<DatasetName>/`).
3. Set `datasets.<name>.enabled` and paths per dataset as needed (see comments in the JSON and dataset-specific scripts for optional keys such as `longitudinal`).
4. For cluster bash jobs, ensure `execution_mode.hpc_enabled` matches your intent (`true`/`1` vs local); optional `FREESURFER_SUBJECTS_DIR` if FreeSurfer outputs are not under `<dataset>/derivatives/freesurfer`.

## Data (example datasets)

Download two datasets [Myelin](https://openneuro.org/datasets/ds003653/versions/1.0.0) and [RD](https://openneuro.org/datasets/ds002748/versions/1.0.5) from OpenNeuro and place them under your dataset root as `Myelin` and `RD`. See each dataset’s terms of use.

## Run pipeline

### data_BIDS 

Build the enabled-dataset list and organise data into BIDS format by running dataset-specific BIDS scripts from `data_BIDS/`:

   ```matlab
   step0a_create_dataset_list('config_hpc.json');
   step0b_organize_bids('config_hpc.json');
   ```

   Use your chosen config filename in place of `config_hpc.json`.

### VBM 

Run VBM preprocessing and analysis

| Step | Run |
|------|-----|
| 1a CAT12 preprocess | `VBM/preprocessing/step1_CAT12/step1a_CAT12_preprocessing_send.sh` |
| 1b CAT12 QC concat | `VBM/preprocessing/step1_CAT12/step1b_cat12_qcReport_concat.sh` |
| 1c visualisation individual| `VBM/preprocessing/step1_CAT12/step1c_visualisation_individual.sh` (bash with display) |
| 1d visualisation combine| `VBM/preprocessing/step1_CAT12/step1d_visualisation_combine.sh` |
| 2 Extract subjects |  `VBM/preprocessing/step2_extract_subjects/step2_run_extract_subjects.m` — see **Manual visual QC** below |
| 3 Smoothing | `VBM/preprocessing/step3_smoothing/step3_run_smooth_TIV.sh` |
| 4a–e COMBAT / metadata | `VBM/preprocessing/step4_combat/` (`step4a_combine_metadata.m`, `step4b_make_mask.sh`, `step4c_combat_input.sh`, `step4d_COMBAT_run_sbatch_send.sh`, `step4e_combat_output.sh`) |
| 5 Statistical analysis | `VBM/analysis/step5_statistical_analysis/step5_runGLM_send.sh` |
| 6a–c Null test | `VBM/analysis/step6_nulltest/` (`step6a_matrix_volume.sh`, `step6b_vol_dense_gen_send.sh`, `step6c_permutation.sh`) |
| 7a–e Parcellation | `VBM/analysis/step7_parcellation/` (`step7a_project_parcellations_on_CAT12MNI.sh`, `step7b_combine_parcellation.sh`, `step7c_parcellate_maps_send.sh`, `step7d_runGLM_parc_send.sh`, `step7e_parcellate_null_maps_send.sh`) |
| 8a-f Consistency | `VBM/analysis/step8_consistency/` |
| 9a-k Covariates | `VBM/analysis/step9_covariates/` |
| 10 Figures | `VBM/analysis/step10_figures/` |

#### Manual visual QC before step 2

After **step 1d**, inspect the generated volumes. For each dataset directory (`${dataset_root}/<Dataset>/`, e.g. `Myelin/`, `RD/`):

1. Copy **`subjects_cat12_passed.txt`** to **`subjects_pass_visualisation_vbm.txt`**.
2. Edit **`subjects_pass_visualisation_vbm.txt`**: delete participant IDs you exclude after visual QC (one BIDS participant ID per line, same format as the CAT12-passed list).

### SBM

Run SBM preprocessing and analysis

| Step | Run |
|------|-----|
| 1 Recon-all | `SBM/preprocessing/step1_recon_all/step1.recon_all.sh` |
| 2a–d Auto QC | `SBM/preprocessing/step2_autoQC/` (`step2a.mriqc_individual.sh`, `step2b.mriqc_group.sh`, `step2c.euler.sh`, `step2d.mriqc_PCA.sh`) |
| 3 Surface vis | `SBM/preprocessing/step3_surfacevis/` (`step3a.fsleyes.sh`, `step3b.combine_fsleyes.sh`) |
| 4 Extract | `SBM/preprocessing/step4_extract_subjects/step4_run_extract_surface.m` |
| 5a–d COMBAT / metadata | `SBM/preprocessing/step5_combat/` (`step5a_combine_metadata.m`, `step5b_combat_surface_input.sh`, `step5c_COMBAT_run_sbatch_send.sh`, `step5d_combat_surface_output.sh`) |
| 6 GLM | `SBM/analysis/step6_statistical_analysis/step6_glmfit.sh` |
| 7a–c Null test | `SBM/analysis/step7_nulltest/` (`step7a_precal_eigenmode.sh`, `step7b_eigentrapping_nulltest_send.sh`, `step7c_permutation_nulltest_send.sh`) |
| 8a–d Parcellation | `SBM/analysis/step8_parcellation/` (`step8a_parcelate_maps.sh`, `step8b_glm_parc.sh`, `step8c_parc_null.sh`, `step8d_ver_null.sh`; or MATLAB `step8*_*(config)`) |
| 9a–e Consistency | `SBM/analysis/step9_consistency/` (`step9a_corr_zmap.m`, `step9b_corr_zmap_parc.m`, `step9c_corr_zmap_null_send.sh`, `step9d_corr_zmap_null_combine.m`, `step9e_corr_zmap_parc_null.m`) |
| 10a–k Covariates | `SBM/analysis/step10_covariates/` |
| 11a–g Sample size | `SBM/analysis/step11_sample_size_effect/` (`step11a_resample_2sitegroup_subdivide_samesize_send.sh`, `step11b_glmfit_resample_2sitegroup_subdivide_samesize_send.sh`, `step11c_corr_map_subdivide_send.sh`, `step11d_corr_zmap_subdivide_2sitegroup_samesize.m`, `step11e_parc_resample_2sitegroup_subdivide_samesize_send.sh`, `step11f_corr_parc_resample_2sitegroup_subdivide_samesize_send.sh`, `step11g_corr_zmap_parc_subdivide_2sitegroup_samesize.m`) |
| 12 Figures | `SBM/analysis/step12_figures/` |

FreeSurfer `recon-all` is driven by `SBM/preprocessing/step1_recon_all/step1.recon_all.sh` (login node: builds `sub_to_recon.txt` from `subject_use.txt` or longitudinal `ses_subject_use.txt`, then submits a SLURM array). Optional: `export FREESURFER_SUBJECTS_DIR=...` if subject folders are not under each dataset’s `derivatives/freesurfer`.

For **SBM**, create **`subjects_pass_visualisation_sbm.txt`** from `subjects_pass_Euler_number_check.txt` (written by `step2c.euler.sh`) after removing subjects that fail visual surface inspection.

## Compatibility

MATLAB R2023a–R2025a.

## Citation

If you use our code in your research, please cite us as follows:

Trang Cao, James C. Pang, Mehul Gajwani, Ashlea Segal, Alex Holmes, Joshua Wiley, Sidhant Chopra, Juan Helen Zhou, Christopher CH Chen, Fang Ji, Ben J Harrison, Christopher G Davey, Toby Constable, Jeggan Tiego, Bree Hartshorn, Jessica Kwee, Mark A. Bellgrove, Alex Fornito, The cross-site reproducibility of MRI morphometric phenotypes in psychiatric disorders, (DOI: [2025.07.09.25331220](https://doi.org/10.1101/2025.07.09.25331220))

## Further details

Please contact trang.cao@monash.edu if you need any further details.

