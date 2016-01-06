datadir='/windows/D/data/space_recall/group/recall'
% datadir='D:\data\cuprisk\group0903';
roi_img_dir=fullfile(datadir,'roi','roi');
roiplotdir=fullfile(datadir,'roi','plots');
basedir='/windows/D/data/space_recall/group/recall/roi/scripts';
% basedir='d:\data\cuprisk\group0903\roi_fd\scripts';
addpath(basedir)

cwd=pwd;
subs=[3:24]+17;
%subs=[1:24];
%outliers=[3 8,13,18,22];%[2,3,6,11];
%subs=setxor(subs,outliers);

% cope_nums=[8:16];
% cd(roi_img_dir)
% roi_files=dir('*.nii.gz');
% 
% for c=1:length(cope_nums),
%     cope_dir=fullfile(datadir,['cope' num2str(cope_nums(c)) '.gfeat'],'cope1.feat');
%     cd(cope_dir)
%     for r=1:length(roi_files),
%         roi_name=roi_files(r).name;
%         [PATHSTR,NAME,EXT,VERSN]=fileparts(roi_files(r).name);
%         [PATHSTR,NAME,EXT,VERSN]=fileparts(NAME);
%         true_psc=load([NAME '.txt']);        
%         roi(r).all(:,c)=true_psc;
%         roi(r).name=roi_files(r).name;
%     end
% end
% 
% %% replace outlier by mean
% % roi(3).all(5,2)=0.19 % replace by mean
% 
% cd(roiplotdir)
% save all_data roi;
% %load all_data


for r=1:length(roi_files)
figure;

% for r=1:1
     
%%% plot
% first, do anova to decide the errorbar
    %addpath('/space/raid2/data/poldrack/cogrev/results')
   f1_num=3; % lag
   f2_num=3; % sm
   fac={'memory','rep'};
    y=roi_mean(r).data;
    y=y(subs,:,:);
    y=squeeze(mean(y,2));
    %;
    % y=[y(:,1) mean(y(:,2:4),2) y(:,5) mean(y(:,6:8),2) y(:,9) mean(y(:,10:12),2) y(:,13) mean(y(:,14:16),2)];
    stats=do_anova2(y,f1_num,f2_num,fac);
    withsub_err=sqrt(stats{4,4}/size(y,1));
    % roi(r).stats_within=stats;
     
 % second, calculate mean
%meanmat=reshape(mean(roi(r).all),8,2);
% meanmat=mean(roi(r).all);
meanmat=mean(y);
% meanmat=[meanmat([1:4 9:12]);meanmat([5:8,13:16])]';
meanmat=[meanmat([1:3]);meanmat(4:6);meanmat([7:9])]';

    % stdmat=std(roi(r).all);
 % use within-subject error
    stdmat=ones(size(meanmat))*withsub_err(1);
     
  % third, print within subj anova_
%     s_names={'Main Effect of Task','Main Effect of Bin','Bin X Task'};  
%     s_index=2:4,
%     thresh=.1
%     for s=1:length(s_index),
%         fprintf('\n%s\n',s_names{s})
%         for r=1:length(roi),
%             pval=roi(r).stats_within{s_index(s),6};
%             if pval<thresh,
%                 fprintf('%s\t %2.3f\n',roi(r).name,pval)
%             end
%         end
%     end    
%     
 % finally, plot
    %figure
    plottitle=strrep(roi_name{r},'_','\_');
    % condnames={'M1','M2','M3','M4','S1','S2','S3','S4'};
    condnames={'R1','R2','R3'};
    %addpath('/space/raid/home/dara/matlab')
    hold on
%     errorbar(meanmat,stdmat,'LineWidth',1)
%     plot(meanmat,'LineWidth',2)
    % barerror(meanmat,stdmat,0.9,'k',{'r';'g';'b'})
    
    %subplot(2,2,r); 
    figure
    barerror(meanmat,stdmat,0.9,'k',{'r';'g';'b'})
    % m=bar(meanmat);grey=[0 0.7 0];
    %set(m,'FaceColor',grey)
    %set(m,'Linewidth',3);
    %errorbar(meanmat,withsub_err,'.k','LineWidth',3)
    set(gca,'XTick',[1:3])
    set(gca,'Xticklabel',condnames);
    set(gca,'FontSize',20)
    %set(gca,'fontname','Arial')
    set(gcf,'Color',[1 1 1]) % set background to white
    title(plottitle)
    legend('Recall','Recogn','Forgot');
    %xlabel('Condition')
    % xlabel(['F = ' num2str(F1) '; P = ' num2str(P1)]);
    ylabel('% signal change')
    
    % text (1,1,['F = ' num2str(F1) '; P = ' num2str(P1)]);
    hold off
    orient tall
    %set(get(m,'parent'), 'position',[0.153957 0.11 0.751043 0.815]);
    print('-dpsc2','-painters','-append',['plots_2bin'])
end

cd(basedir);
