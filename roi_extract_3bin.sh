roidir=/windows/E/data/recall_singletrial/pattern/roi/roi
cd $roidir
rois=`ls *mm.nii.gz`
feat_dir=/windows/E/data/recall_singletrial/group/
start_cope=4
end_cope=9
ppheight=50
# ppheight=110

 for ((  c = $start_cope ;  c <= $end_cope;  c++  ))
 do
   echo "cope: $c"
   cd $feat_dir/cope$c.gfeat/cope1.feat
   echo "starting avwmaths..."
   fslmaths filtered_func_data.nii.gz -div mean_func.nii.gz -mul $ppheight pctchange_data    
   echo "begin avwmeants..." 
    for rx in $rois
	do    
	r=`echo $rx | sed "s/.nii.gz//"`
	echo $r
	fslmeants -i pctchange_data -o $r\.txt -m $roidir/$r 
	ls $r\.txt
    done
    echo "removing unnecessary files..."
    rm -f pctchange_data.nii.gz
done
