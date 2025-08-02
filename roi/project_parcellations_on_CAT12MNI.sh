


#project Tian subcortex
flirt -in /home/trangc/kg98/trangc/atlases/Tian_subcortical/3T/Subcortex-Only/Tian_Subcortex_S1_3T_2009cAsym.nii.gz -ref /home/trangc/kg98_scratch/trangc/toolbox/spm12/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii -applyxfm -usesqform -noresampblur -interp nearestneighbour -out /home/trangc/kg98/trangc/atlases/Tian_subcortical/CAT12MNI/Tian_Subcortex_S1_3T_2009cAsym_CAT12MNI


# project cerebellum
flirt -in /home/trangc/kg98/trangc/atlases/Human_cerebellum/Buckner-whole_1mm.nii.gz -ref /home/trangc/kg98_scratch/trangc/toolbox/spm12/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii -applyxfm -usesqform -noresampblur -interp nearestneighbour -out /home/trangc/kg98/trangc/atlases/Human_cerebellum/Buckner-whole_1mm_CAT12MNI.nii.gz

# project Schaefer cortex
flirt -in /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/MNI/Schaefer2018_100Parcels_7Networks_order_FSLMNI152_1mm.nii.gz -ref /home/trangc/kg98_scratch/trangc/toolbox/spm12/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii -applyxfm -usesqform -noresampblur -interp nearestneighbour -out /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/CAT12MNI/Schaefer2018_100Parcels_7Networks_order_CAT12MNI.nii

flirt -in /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/MNI/Schaefer2018_200Parcels_7Networks_order_FSLMNI152_1mm.nii.gz -ref /home/trangc/kg98_scratch/trangc/toolbox/spm12/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii -applyxfm -usesqform -noresampblur -interp nearestneighbour -out /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/CAT12MNI/Schaefer2018_200Parcels_7Networks_order_CAT12MNI.nii

flirt -in /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/MNI/Schaefer2018_300Parcels_7Networks_order_FSLMNI152_1mm.nii.gz -ref /home/trangc/kg98_scratch/trangc/toolbox/spm12/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii -applyxfm -usesqform -noresampblur -interp nearestneighbour -out /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/CAT12MNI/Schaefer2018_300Parcels_7Networks_order_CAT12MNI.nii

flirt -in /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/MNI/Schaefer2018_400Parcels_7Networks_order_FSLMNI152_1mm.nii.gz -ref /home/trangc/kg98_scratch/trangc/toolbox/spm12/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii -applyxfm -usesqform -noresampblur -interp nearestneighbour -out /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/CAT12MNI/Schaefer2018_400Parcels_7Networks_order_CAT12MNI.nii

flirt -in /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/MNI/Schaefer2018_500Parcels_7Networks_order_FSLMNI152_1mm.nii.gz -ref /home/trangc/kg98_scratch/trangc/toolbox/spm12/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii -applyxfm -usesqform -noresampblur -interp nearestneighbour -out /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/CAT12MNI/Schaefer2018_500Parcels_7Networks_order_CAT12MNI.nii

flirt -in /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/MNI/Schaefer2018_600Parcels_7Networks_order_FSLMNI152_1mm.nii.gz -ref /home/trangc/kg98_scratch/trangc/toolbox/spm12/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii -applyxfm -usesqform -noresampblur -interp nearestneighbour -out /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/CAT12MNI/Schaefer2018_600Parcels_7Networks_order_CAT12MNI.nii

flirt -in /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/MNI/Schaefer2018_700Parcels_7Networks_order_FSLMNI152_1mm.nii.gz -ref /home/trangc/kg98_scratch/trangc/toolbox/spm12/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii -applyxfm -usesqform -noresampblur -interp nearestneighbour -out /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/CAT12MNI/Schaefer2018_700Parcels_7Networks_order_CAT12MNI.nii

flirt -in /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/MNI/Schaefer2018_800Parcels_7Networks_order_FSLMNI152_1mm.nii.gz -ref /home/trangc/kg98_scratch/trangc/toolbox/spm12/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii -applyxfm -usesqform -noresampblur -interp nearestneighbour -out /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/CAT12MNI/Schaefer2018_800Parcels_7Networks_order_CAT12MNI.nii

flirt -in /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/MNI/Schaefer2018_900Parcels_7Networks_order_FSLMNI152_1mm.nii.gz -ref /home/trangc/kg98_scratch/trangc/toolbox/spm12/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii -applyxfm -usesqform -noresampblur -interp nearestneighbour -out /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/CAT12MNI/Schaefer2018_900Parcels_7Networks_order_CAT12MNI.nii

flirt -in /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/MNI/Schaefer2018_1000Parcels_7Networks_order_FSLMNI152_1mm.nii.gz -ref /home/trangc/kg98_scratch/trangc/toolbox/spm12/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii -applyxfm -usesqform -noresampblur -interp nearestneighbour -out /home/trangc/kg98/trangc/atlases/Human_cortical/Schaefer/CAT12MNI/Schaefer2018_1000Parcels_7Networks_order_CAT12MNI.nii

