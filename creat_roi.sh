# !sh/bin

fslmaths /windows/D/data/recall_singletrial/group/cope1.gfeat/cope1.feat/cluster_mask_zstat1.nii.gz -thr 1 -uthr 1 -bin ../roi/IPLLOC
fslmaths /windows/D/data/recall_singletrial/group/cope1.gfeat/cope1.feat/cluster_mask_zstat1.nii.gz -thr 2 -uthr 2 -bin ../roi/LMFG