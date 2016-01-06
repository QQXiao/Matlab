#! /bin/bash 

subjs=( 673 692 704 710 781 1050 1204 1306 1309 1359 1360 1365 )
#subjs=( 1309 )
conds=( brokenrake_post brokenrake_pre hand_post hand_pre nohand rake_post rake_pre )
#conds=( brokenrake_post )

pipeline="firstlevel_motioncorr"

dir="/Volumes/Storage/freylab_projects/exp38-01_handspace/mri_data"


echo ""
echo "Do you want to reduce the field of view of highres anatomical,"
echo "and skull-strip it?"
echo -n "y/n: "
read preprocess
echo ""
echo "Do you want to downsample the highres anatomical?"
echo -n "y/n: "
read downsample
echo ""
echo "Do you want to register highres_reducedfov to standard, and example_func to highres_reducedfov?"
echo -n "y/n: "
read registration



if [ ${preprocess} = "y" ]
then
        for subj in ${subjs[@]}
        do
        
                echo ""
                echo "###############################"
                echo "processing subject ${subj}"
                echo "###############################"
                echo ""

                rawDir="${dir}/${subj}/raw"
        
#{{{    reduce the field of view of the highres anatomical image:

                #determine xmin ymin and zmin in fslview:
                xsize=364
                ysize=372
                zsize=176
                echo ""
                echo "determine xmin ymin and zmin in fslview and close when done"
                echo "xsize=${xsize}; ysize=${ysize}; zsize=${zsize}"

                highres=${rawDir}/${subj}_highres1
                fslview ${highres}

                echo ""
                echo "enter parameters to define new field of view and press Enter"
                echo "usage: <xmin> <ymin> <zmin>"
        
                read xmin ymin zmin
                if [ -z ${xmin} ] || [ -z ${ymin} ] || [ -z ${zmin} ]
                then
                        echo ""
                        echo "make sure to enter the 3 values required!"
                        echo "xsize=364; ysize=372; zsize=176"
                        echo "usage: <xmin> <ymin> <zmin>"
                        read xmin ymin zmin
                fi

                highresReducedFov=${highres}_reducedfov
        
                fslroi ${highres} ${highresReducedFov} ${xmin} ${xsize} ${ymin} ${ysize} ${zmin} ${zsize}
                
                #check field of view in fslview:
                echo ""
                echo "check field of view in fslview and close when done"
                fslview ${highresReducedFov}
#}}}

#{{{    skull strip the highres with reduced field of view:
                echo ""
                echo "enter parameters for skull stripping and press Enter"
                echo "usage: <-f> <-g>"
                echo "default values: f=0.5 and g=0"
        
                read f g
                if [ -z ${f} ] || [ -z ${g} ]
                then
                        echo ""
                        echo "enter parameters for skull stripping and press Enter"
                        echo "usage: <-f> <-g>"
                        read f g
                fi
        
                highresReducedFovBrain=${highresReducedFov}_brain
        
                bet ${highresReducedFov} ${highresReducedFovBrain} -f ${f} -g ${g}
        
                #check result of skull stripping in fslview:
                echo ""
                echo "check result of skull stripping in fslview and close when done"
                fslview ${highresReducedFov} ${highresReducedFovBrain} -l Copper
#}}}    

        done #subj
        
fi #if preprocess


#now the automated jobs that don't require user input:
echo ""
echo ""
echo "now the automated jobs that don't require user input:"

for subj in ${subjs[@]}
do
        
        echo ""
        echo "###############################"
        echo "processing subject ${subj}"
        echo "###############################"
        echo ""

#{{{create a copy of the highres anatomical that has a 1x1x2 voxel size:
        if [ ${downsample} = "y" ]
        then
                echo "downsampling highres anatomical"

                xsize=364
                ysize=372
                zsize=176
                xsizeNew=$(echo "${xsize}/2" | bc)
                ysizeNew=$(echo "${ysize}/2" | bc)
                zsizeNew=$(echo "${zsize}/2" | bc)


                rawDir="${dir}/${subj}/raw"
                highres=${rawDir}/${subj}_highres1
                highresReducedFov=${highres}_reducedfov
                highresReducedFovBrain=${highresReducedFov}_brain
                highresReducedFovBrainDownsampled=${highresReducedFovBrain}_downsampled

                fslcreatehd ${xsizeNew} ${ysizeNew} ${zsizeNew} 1 1 1 2 1 0 0 0 16  ${highresReducedFovBrainDownsampled}_tmp
                flirt -in ${highresReducedFov} -applyxfm -init /usr/local/fsl4.1.1/etc/flirtsch/ident.mat -out ${highresReducedFovBrainDownsampled} -paddingsize 0.0 -interp trilinear -ref ${highresReducedFovBrainDownsampled}_tmp
                rm ${highresReducedFovBrainDownsampled}_tmp.nii.gz
        fi #downsample
#}}}

#{{{make necessary modifications within xxx.feat/reg/ folders:

        #copy necessary files to xxx.feat/reg:
        echo ""
        echo "copying files to reg/ folders in feat folders"
        
        for cond in ${conds[@]}
        do
                echo "#${cond}"
                condDir=${dir}/${subj}/${pipeline}/${cond}.feat
                if [ ${preprocess} = "y" ]
                then
                        cp ${highresReducedFovBrain}.nii.gz ${condDir}/reg/highres_reducedfov.nii.gz
                fi
                if [ ${downsample} = "y" ]
                then            
                        cp ${highresReducedFovBrainDownsampled}.nii.gz ${condDir}/reg/highres_reducedfov_downsampled.nii.gz
                fi
        done
#}}}

#{{{register highres anatomical with smaller field of view to standard space
        if [ ${registration} = "y" ]
        then
                echo ""
                echo "register highres anatomical with smaller field of view to standard space in ${subj}/${pipeline}/brokenrake_post.feat/reg/"
        
                firstCondDir=${dir}/${subj}/${pipeline}/brokenrake_post.feat
        
                echo "#linear registration"
                flirt -ref ${firstCondDir}/reg/standard -in ${firstCondDir}/reg/highres_reducedfov -out ${firstCondDir}/reg/highres_reducedfov2standard -omat ${firstCondDir}/reg/highres_reducedfov2standard.mat -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear  
        
                echo "#non-linear registration"
                fslmaths /usr/local/fsl4.1.1/data/standard/MNI152_T1_2mm ${firstCondDir}/reg/standard_head
                fslmaths /usr/local/fsl4.1.1/data/standard/MNI152_T1_2mm_brain_mask_dil ${firstCondDir}/reg/standard_mask
                fnirt --in=${firstCondDir}/reg/highres_reducedfov --aff=${firstCondDir}/reg/highres_reducedfov2standard.mat --cout=${firstCondDir}/reg/highres_reducedfov2standard_warp --iout=${firstCondDir}/reg/highres_reducedfov2standard --jout=${firstCondDir}/reg/highres_reducedfov2standard_jac --config=T1_2_MNI152_2mm --ref=${firstCondDir}/reg/standard_head --refmask=${firstCondDir}/reg/standard_mask --warpres=10,10,10
        
                #copy outputs to ther xxx.feat/reg/ folders:
                echo ""
                echo "copy outputs of registration to other xxx.feat/reg/ directories"
                for cond in ${conds[@]:1}       #all but first element
                do
                        echo "#${cond}"
                        condDir=${dir}/${subj}/${pipeline}/${cond}.feat
                        cp ${firstCondDir}/reg/highres_reducedfov2standard.mat ${condDir}/reg/highres_reducedfov2standard.mat
                        cp ${firstCondDir}/reg/standard_head.nii.gz ${condDir}/reg/standard_head.nii.gz
                        cp ${firstCondDir}/reg/standard_mask.nii.gz ${condDir}/reg/standard_mask.nii.gz
                        cp ${firstCondDir}/reg/highres_reducedfov2standard_warp.nii.gz ${condDir}/reg/highres_reducedfov2standard_warp.nii.gz
                        cp ${firstCondDir}/reg/highres_reducedfov2standard.nii.gz ${condDir}/reg/highres_reducedfov2standard.nii.gz
                        cp ${firstCondDir}/reg/highres_reducedfov2standard_jac.nii.gz ${condDir}/reg/highres_reducedfov2standard_jac.nii.gz
                done
#}}}

#{{{register example_func to highres with smaller field of view, and the latter to standard:
                echo ""
                echo "register example_func to highres anatomical with smaller field of view"
                for cond in ${conds[@]}
                do
                        echo "#${cond}"
                        condDir=${dir}/${subj}/${pipeline}/${cond}.feat
                        exampleFunc=${condDir}/reg/example_func
                        #register:
                        flirt -in ${exampleFunc} -ref ${condDir}/reg/highres_reducedfov -omat ${condDir}/reg/example_func2highres_reducedfov_mutualinfo.mat -out ${condDir}/reg/example_func2highres_reducedfov_mutualinfo -bins 256 -cost mutualinfo -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 7
                        #compute inverse matrix:
                        convert_xfm -omat ${condDir}/reg/highres_reducedfov2example_func_mutualinfo.mat -inverse ${condDir}/reg/example_func2highres_reducedfov_mutualinfo.mat
                done
#}}}
        fi #registration

done    #subj