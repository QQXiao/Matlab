function out = single_event_model(featdir,std_ref)
    % Usage: single_event_model(featdir,std_ref)
    % Takes a feat directory, and runs a ridge regression (using ridge_hkb()) 
    % on the filtered_func_data.img file within.  It uses the onsets
    % in the first onsets file, so all trials must be in that file.
    %
    % Returns a 4D nifti file of beta estimates, and a 3D nifti of lambda
    % values estimated by ridge_hkb().  These files will be located in
    % a directory called 'ridge reg' within the feat directory
    %
    % Created by Russ Poldrack      September 2007 
    % Edited by Marisa Geoghegan    October 11, 2007
    % Edited by Jeanette Mumford    Dec 11, 2007
    % Edited by Russ Poldrack	    August 9, 2008
    % setting up directory called ridge_reg in the feat directory to
    % store results

    ridge_path = strcat(featdir, '/ridge_reg/');    
    mkdir(ridge_path)

    % read design matrix
    design = read_fsl_design2(featdir);
    
    %load onsets
    onsetf = design.custom1;
    ons = load(onsetf);
    nruns = length(ons);
    
    %load mask
    
    cd(featdir)

    %this loop figures out if we're dealing with nifti or analyze
    if exist('mask.nii')+exist('mask.nii.gz')>0
      mask_loc=dir('mask.*');
      mask_loc=mask_loc.name;
    else
      mask_loc=dir('mask.img*');
      mask_loc=mask_loc.name;
    end
   
    maskf = strcat(featdir,'/', mask_loc);
    maskfile = load_nii_zip(maskf);
    mask = maskfile.img;
    
    %import data and convert from int16 into double

  
    dataf = char(design.feat_files);
    datafile = load_nii_zip(dataf);
    data = datafile.img;
    data = double(data); 

    TR=design.tr;
    ntp=design.npts;
    onsets = round((ons(:,1)+TR)/2);
    
    %single event regressors
    X_single = zeros(ntp,length(onsets));
    hrf = spm_hrf(TR);
    trial = zeros(length(onsets),ntp+length(hrf)-1);

    
    for t = 1:length(onsets)
    
        ssf = zeros(1,ntp);
        ssf(onsets(t))=1;
        trial(t,:) = conv(ssf,hrf); 
        X_single(:,t) = trial(t,1:ntp)';
    
    end

   % We need to HP filter the design.  This should be exactly what 
   % FSL already did to the data. 
   % The reason I'm not starting with the original data
   % is because I would like to retain the smoothing and scaling that was 
   % done to filtered_func_data
  
   cut=design.paradigm_hp/design.tr;
   sigN2=(cut/(sqrt(2)))^2;
   K=toeplitz(1/sqrt(2*pi*sigN2)*exp(-[0:(ntp-1)].^2/(2*sigN2)));
   K=spdiags(1./sum(K')', 0, ntp,ntp)*K;
   
    H = zeros(ntp,ntp); % Smoothing matrix, s.t. H*y is smooth line 
    X = [ones(ntp,1) (1:ntp)'];
     for  k = 1:ntp
       W = diag(K(k,:));
       Hat = X*pinv(W*X)*W;
       H(k,:) = Hat(k,:);
     end    

   F=eye(ntp)-H;
   
   X_single_hp=F*X_single;


    %beta_est is the ridge estimate

    beta_est=zeros(size(data,1),size(data,2),size(data,3),length(onsets));
    beta_ls_est=zeros(size(data,1),size(data,2),size(data,3),length(onsets));
    lambda=zeros(size(data,1),size(data,2),size(data,3));
    fprintf('Looping...');
    
    %loop through voxels in mask and run ridge regression
        
    time = 0;
    tic;
    for x = 1:size(data,1)
      fprintf('%d %d \n',x,size(data,1));
        for y = 1:size(data,2) 
            for z = 1:size(data,3)
                if mask(x,y,z)>0
                    foo(:,1)=data(x,y,z,:);
                    foo=F*foo(:);
                    lr=ridge_hkb(foo,X_single_hp);
                    beta_est(x,y,z,:) = lr.b_hkb;
                    lambda(x,y,z) = lr.k_hkb;
                end
            end
        end
    end
    time = toc;
    fprintf(' %f sec\n \n', time);
    
    %Save data
    fprintf('\nSaving data...\n');
    time2 = 0;
    tic

    %use datafile as a template for 4D beta_est data
    %  You'll need to edit this to reflect the path where you want to save your results
    fname_beta_est = strcat(ridge_path, '/ridge_beta.nii');
    beta_est_nii = datafile;     %uses 'datafile' as a templat
    beta_est_nii.img = beta_est;  %setting the image data 
    beta_est_nii.hdr.dime.dim(5)=nruns;   %Replace 204 with number of onsets=nruns  
    beta_est_nii.hdr.dime.datatype=16;   % how the computer stores the data
    beta_est_nii.hdr.dime.bitpix=32;     %how the computer stores the data
    save_nii(beta_est_nii, fname_beta_est);  %finally saving the data

    %flips the image so it is correct in fslview
    system(sprintf(['fslorient -forceradiological %s'], fname_beta_est));
  
    %use maskfile as a template for 3D lambda data
    fname_lambda = strcat(ridge_path, '/lambda_color.nii');
    lambda_nii = maskfile;
    lambda_nii.img = lambda;
    lambda_nii.hdr.dime.datatype=16;
    lambda_nii.hdr.dime.bitpix=32;
    save_nii(lambda_nii, fname_lambda);
    system(sprintf(['fslorient -forceradiological %s'], fname_lambda));
    time2=toc;
    fprintf(' %f sec\n \n', time2);
    
    %Standardization
    fprintf('Standardization...');
    std_beta_est = strcat(ridge_path, '/ridge_beta_std');
    std_lambda = strcat(ridge_path, '/lambda_color_std');
    std_beta_ls_est = strcat(ridge_path, '/ls_beta_std');
    mat_file = strcat(featdir, '/reg/example_func2standard.mat');
    time3 = 0;
    tic
    if ~exist('std_ref'),
       std_ref='/space/raid/fmri/fsl/etc/standard/avg152T1.img';
    end;

    system(sprintf(['applyxfm4D %s %s %s %s -singlematrix'],fname_beta_est, std_ref, std_beta_est, mat_file));

    system(sprintf(['flirt -in %s -ref %s -out %s -applyxfm  -init %s'], fname_lambda, std_ref,std_lambda, mat_file));
    time3 = toc;
    fprintf(' %f sec\n \n', time3);
      
  
