datadir='/windows/E/data/recall_singletrial/group'
roi_img_dir=fullfile('/windows/E/data/recall_singletrial/pattern','roi','roi');
roiplotdir=fullfile(datadir,'roi','plots');
basedir='/windows/E/data/recall_singletrial/group/roi/scripts';
addpath(basedir)

cwd=pwd;
subs=[1:22];

cope_nums=[4:9];
cd(roi_img_dir)
roi_files=dir('*mm.nii.gz');

for c=1:length(cope_nums),
    cope_dir=fullfile(datadir,['cope' num2str(cope_nums(c)) '.gfeat'],'cope1.feat');
    cd(cope_dir)
    for r=1:length(roi_files),
        roi_name=roi_files(r).name;
        [PATHSTR,NAME,EXT,VERSN]=fileparts(roi_files(r).name);
        [PATHSTR,NAME,EXT,VERSN]=fileparts(NAME);
        true_psc=load([NAME '.txt']);        
        roi(r).all(:,c)=true_psc;
        roi(r).name=roi_files(r).name;
    end
end

%% replace outlier by mean
% roi(3).all(5,2)=0.19 % replace by mean

cd(roiplotdir)
save all_data roi;
%load all_data


%for r=1:length(roi_files)

for r=1:4
     
%%% plot
% first, do anova to decide the errorbar
    %addpath('/space/raid2/data/poldrack/cogrev/results')
   f1_num=2; % mem
   f2_num=3; % rep
   fac={'memory','rep'};
    y=roi(r).all;
    y=y(subs,:);
    stats=do_anova2(y,f1_num,f2_num,fac);
    withsub_err=sqrt(stats{4,4}/size(y,1));
    
    meanmat=mean(y);
    meanmat=[meanmat([1:3]);meanmat(4:6)]';
    stdmat=ones(size(meanmat))*withsub_err(1);

    % finally, plot
    %figure
    %plottitle=strrep(roi(r).name,'_','\_');
    plottitle=roi(r).name(1:4); 
    if r==4, plottitle='LAnG';end
    
    condnames={'P1','P2','P3'};
    hold on
    subplot(2,2,r); 
    %figure
    barerror(meanmat,stdmat,0.9,'k',{'r';'g';'b'})
    set(gca,'XTick',[1:3])
    set(gca,'Xticklabel',condnames);
    set(gca,'FontSize',20)
    %set(gca,'ylim',[0 0.8]);
    set(gca,'fontname','Arial')
    set(gcf,'Color',[1 1 1]) % set background to white
    title(plottitle)
    if r==3 legend('Recalled','Forgotten'); end
    ylabel('% signal change')
    
    hold off
    orient tall
    %set(get(m,'parent'), 'position',[0.153957 0.11 0.751043 0.815]);
    print('-dpsc2','-painters','-append',['plots_2bin'])
end

cd(basedir);
