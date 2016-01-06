function out = single_event_model(featdir,write_std_image,save_lambda,use_raw)
    % Usage: single_event_model2(featdir,write_std_image,save_lambda)
    % Takes a feat directory, and runs a ridge regression (using ridge_hkb()) 
    % on the filtered_func_data.img file within.
    %
    % write_std_image - set to 1 to create standard space files
    % save_lambda - set to 1 to save lambda images
    % use_raw - set to 1 to use raw data rather than filtered_func_data
    %
    % Returns a 4D nifti file of beta estimates, and a 3D nifti of lambda
    % values estimated by ridge_hkb().
    %
    % Created by Russ Poldrack      September 2007 
    % Edited by Marisa Geoghegan    October 11, 2007
    % 2009/11/7 Jeanette Mumford:  Changed so all onset files will be
    % read in and both ls and ridge results are saved
    % 2009/11/9 Russ Poldrack: added separate estimates for each condition
    
    addpath /space/raid/fmri/local/matlab/Ridge/
    addpath /space/raid/fmri/local/matlab/
    addpath /space/raid/fmri/NIFTI_20090909/

    if ~exist('write_std_image')
      write_std_image=0;
    end
    if ~exist('save_lambda')
      save_lambda=0;
    end
    if ~exist('use_raw')
      use_raw=0
      raw_flag='';
    end
    if use_raw==1,
      raw_flag='_raw';
    end
    
    save_pth=[featdir,'/stats'];

    design = read_fsl_design2(featdir);
    
    %load onsets

    onscond=[];
    ons=[];
    condnames={};
    goodconds=[];
    
    for evnum=1:design.evs_orig
      condnames(evnum)={eval(sprintf('design.evtitle%d',evnum))};
      onsetf_loop=sprintf('design.custom%d', evnum);
      ons_loop=load(eval(onsetf_loop));
      % added by RP, 11/8/09
      % skips over single-column onset files (e.g., motion parameters)
      if size(ons_loop,2)==3,
         goodconds=[goodconds evnum];
      	 ons_loop=ons_loop(ons_loop(:,3)~=0,:);
      	 ons=[ons;ons_loop];
         onscond=[onscond ones(1,length(ons_loop))*evnum];
      end

    end
    goodconds=unique(goodconds);

    nruns = length(ons);
    
    %load mask
    maskf = strcat(featdir, '/mask.nii.gz');
    maskfile = load_nii_zip(maskf);
    mask = maskfile.img;
    
    %import data and convert from int16 into double
    if use_raw,
      dataf=strcat(design.feat_files{1},'.nii.gz');
    else,
      dataf = strcat(featdir, '/filtered_func_data.nii.gz');
    end
    
    datafile = load_nii_zip(dataf);
    data = datafile.img;
    data = double(data); 
    

    TR=design.tr;
    ntp=design.npts;
    onsets = round((ons(:,1)+TR)/TR);
    

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

   % We need to HP filter the design.  This is an approximation to what 
   % FSL does.  Note the data are already HP filtered and I'm (Jeanette)
   % assuming that this approximation is close enough to what has been
   % done to the data.  The reason I'm not starting with the original
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
        
    for x = 1:size(data,1)
      fprintf('%d %d \n',x,size(data,1));
        for y = 1:size(data,2) 
            for z = 1:size(data,3)
%        for y = 24:26
%            for z = 12:13
                 if mask(x,y,z)>0
                    foo=squeeze(data(x,y,z,:));
                    if use_raw,  % high-pass filter the raw data
                      foo=F*foo;
                    end
                    
                    lr=ridge_hkb(foo,X_single_hp);
                    if ~isnan(lr.b_hkb),
                      beta_est(x,y,z,:) = lr.b_hkb;
                      lambda(x,y,z) = lr.k_hkb;
                      beta_ls_est(x,y,z,:)=lr.b_ls;
                    end
                    
                end
            end
        end
    end

    
    %Save data
    fprintf('\nSaving data...\n');

    %use datafile as a template for 4D beta_est data
    %  You'll need to edit this to reflect the path where you want to
    % save your results
    mat_file = strcat(featdir, '/reg/example_func2standard.mat');
    std_ref=sprintf('%s/data/standard/MNI152_T1_2mm.nii.gz', ...
                    getenv('FSLDIR'))
    
    for condition=goodconds,
      condition_ons=find(onscond==condition);
      fprintf('writing RR image for %s...\n',condnames{condition});
      fname_beta_est = sprintf('%s/pe%d_ridge_beta%s.nii',save_pth,condition,raw_flag);
      beta_est_nii = datafile;     %uses 'datafile' as a templat
      beta_est_nii.img = beta_est(:,:,:,condition_ons);  %setting the image data 
      beta_est_nii.hdr.dime.dim(5)=length(condition_ons);   %Replace 204 with number of onsets=nruns  
      beta_est_nii.hdr.dime.datatype=16;   % how the computer stores the data
      beta_est_nii.hdr.dime.bitpix=32;     %how the computer stores the data
      save_untouch_nii(beta_est_nii, fname_beta_est);  %finally saving the data
      system(sprintf('gzip -f %s',fname_beta_est));
     
      %flips the image so it is correct in fslview
      system(sprintf(['fslorient -forceradiological %s.gz'], fname_beta_est));

      if write_std_image,
        fprintf('writing standard space image for %s...\n',condnames{condition});
        std_beta_est = sprintf('%s/pe%d_ridge_beta%s_std.nii',save_pth, ...
                                 condition,raw_flag);
        system(sprintf(['sge qsub applyxfm4D %s.gz %s %s %s -singlematrix'], fname_beta_est, std_ref,std_beta_est, mat_file));
      end
      
  
      %Save least squares estimates
      fprintf('writing LS image for %s...\n',condnames{condition});

      fname_beta_ls_est = sprintf('%s/pe%d_ls_beta%s.nii',save_pth,condition,raw_flag);
      beta_ls_est_nii = datafile;     %uses 'datafile' as a templat
      beta_ls_est_nii.img = beta_ls_est(:,:,:,condition_ons);  %setting the image data 
      beta_ls_est_nii.hdr.dime.dim(5)=length(condition_ons);   %Replace 204 with number of onsets=nruns  
      beta_ls_est_nii.hdr.dime.datatype=16;   % how the computer stores the data
      beta_ls_est_nii.hdr.dime.bitpix=32;     %how the computer stores the data
      save_untouch_nii(beta_ls_est_nii, fname_beta_ls_est);  %finally saving the data
      system(sprintf('gzip -f %s',fname_beta_ls_est));
      %flips the image so it is correct in fslview
      system(sprintf(['fslorient -forceradiological %s.gz'], ...
                     fname_beta_ls_est));
      
      if write_std_image,
        fprintf('writing standard space image...\n');
        std_beta_ls_est = sprintf('%s/pe%d_ls_beta%s_std.nii',save_pth, ...
                                 condition,raw_flag);
        system(sprintf(['sge qsub applyxfm4D %s.gz %s %s %s -singlematrix'], fname_beta_ls_est, std_ref,std_beta_ls_est, mat_file));
      end
      
 
      %use maskfile as a template for 3D lambda data
      if save_lambda,
        fprintf('writing lambda image...\n');
        fname_beta_ls_est = sprintf('%s/pe%d_lambda%s.nii',save_pth,condition,raw_flag);
        lambda_nii = maskfile;
        lambda_nii.img = lambdat(:,:,:,condition_ons);
        lambda_nii.hdr.dime.datatype=16;
        lambda_nii.hdr.dime.bitpix=32;
        save_untouch_nii(lambda_nii, fname_lambda);
        system(sprintf('gzip -f %s',fname_lambda));
        system(sprintf(['avworient -forceradiological %s.gz'], ...
                       fname_lambda));
       end

    end
  
