# !/bin/sh
# create an image with a spherical ROI given voxel-based coordinates in FSL. 
# USAGE: makeroi.sh <voxel-based XYZ coordinates (in quotes)> <output filename> [options]
#  options: -r <sphere radius> default=6mm
#           -t <template> default=FSL's avg152T1_brain

# maskimg=/mnt/hgfs/wind_d/cup/fsl_analysis/group/cope1.gfeat/cope1.feat/stats/zstat1.nii.gz
# fslmaths $maskimg -thr 2.3 -bin risk_norisk__mask_th2.3

#maskimg=/mnt/hgfs/wind_d/cup/fsl_analysis/group/cope2.gfeat/cope1.feat/stats/zstat1.nii.gz
#fslmaths $maskimg -thr 2.3 -bin win_loss__mask_th2.3


creat_roi()
{

template=/usr/local/fsl/etc/standard/avg152T1_brain
sphere_radius=$size # size
tempoutfile=tmp_roicoord_image # this will be deleted after we create the sphere
#maskimg=allrev_NR_mask_th2.3

# first create an image with a single voxel at the center of the ROI sphere
echo "creating initial image with voxel at sphere center:"
echo "avwmaths $template -roi  ${vox[0]} 1 ${vox[1]} 1 ${vox[2]} 1 0 1 $tempoutfile"
fslmaths $template -roi  ${vox[0]} 1 ${vox[1]} 1 ${vox[2]} 1 0 1 $tempoutfile

# convolve to make a sphere
echo "convolving image to get sphere:"
echo "avwconv -i $tempoutfile -s $sphere_radius -o $tempoutfile\_tmp"
#fslmaths -i $tempoutfile -s $sphere_radius -o $tempoutfile\_tmp

fslmaths $tempoutfile -fmean -kernel sphere $size -fmean $tempoutfile\_tmp

# convert to abs value then binary (0/1s)
echo "converting ROI image to binary (0/1s)..."

fslmaths $tempoutfile\_tmp -abs $tempoutfile\_abs
fslmaths $tempoutfile\_abs -bin $tempoutfile\_tmp

# mask with the activagtion map
# echo "masking with the activation map"
# fslmaths $tempoutfile\_tmp -mul $maskimg ../roi/roi\_$outputfile\_$size\mm

fslmaths $tempoutfile\_tmp -mul 1 ../roi/$outputfile\_$size\mm

# clean up
rm -f $tempoutfile*
}

#Left_angular
outputfile=langular_-60_-52_20
vox=(75 37 46)
size=4
maskimg=risk_norisk__mask_th2.3
creat_roi

#ACC
outputfile=ACC_12_38_0
vox=(39 82 36)
size=4
maskimg=risk_norisk__mask_th2.3
creat_roi

#vmpfc
outputfile=vmpfc_-2_38_-24
vox=(46 82 24)
size=4
maskimg=risk_norisk__mask_th2.3
creat_roi

