function nii_struc=load_nii_zip(file,img_idx)
  %This function is the same as load_nii, except it will unzip a nii.gz
  %file, read it in and rezip it.
  %nii_struc:  The usual output from load_nii
  %file:  The nifi file you want to read in
  % You must have the Rotman Matlab Nifti tools  
  % Jeanette Mumford, Jan 2008

 if ~exist('img_idx','var') | isempty(img_idx)
     img_idx=[];
 end
 
  
 
[pth,name, ext]=fileparts(file);
     if strcmp(ext, '.gz')
      system(['gunzip '  file]); 
      nii_struc=load_untouch_nii(fullfile(pth,name),img_idx);
      system(['gzip ' fullfile(pth,name) ]); 
     else
       nii_struc=load_untouch_nii(file,img_idx);
     end
     
