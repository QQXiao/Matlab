datadir='/windows/D/data/space_learning/group/word_sl_group'
% datadir='D:\data\cuprisk\group0903';
roi_img_dir=fullfile(datadir,'roi','roi');
roiplotdir=fullfile(datadir,'roi','plots');
basedir='/windows/D/data/space_learning/group/word_sl_group/roi/scripts';
% basedir='d:\data\cuprisk\group0903\roi_fd\scripts';
addpath(basedir)

cwd=pwd;
subs=[1:19];
%outliers=[4,14];%[2,3,6,11];
%subs=setxor(1:16,outliers);

cope_nums=[8:23];
cd(roi_img_dir)
roi_files=dir('*.nii.gz');

for c=1:length(cope_nums),
    cope_dir=fullfile(datadir,['cope' num2str(cope_nums(c)) '_19sub.gfeat'],'cope1.feat');
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

a=[1 3 2 5];
%for r=1:length(roi_files)
for b=1:length(a)
    r=a(b);
%%% plot
% first, do anova to decide the errorbar
    %addpath('/space/raid2/data/poldrack/cogrev/results')
   f1_num=2; % lag
   f2_num=2; % sm
   fac={'lag','sm'};
%     y=roi(r).all; % y(3,5)=0.27; y(6,13)=0.3;
%     summed=[mean(y(:,1:4),2) mean(y(:,5:8),2) mean(y(:,9:12),2) mean(y(:,13:16),2)]*4;
%     stats=do_anova2(y,f1_num,f2_num,fac);
%     withsub_err=sqrt(stats{6,4}/size(y,1));
    % roi(r).stats_within=stats;
     
 % second, calculate mean
%meanmat=reshape(mean(roi(r).all),8,2);
% meanmat=mean(roi(r).all);
% meanmat=mean(summed);
% meanmat=[meanmat([1:2]); meanmat([3:4])]';

% meanmat=[meanmat([1:4 9:12]);meanmat([5:8,13:16])]';
% meanmat=[meanmat([1:2 5:6]);meanmat([3:4 7:8])]';

    % stdmat=std(roi(r).all);
 % use within-subject error
%     stdmat=ones(size(meanmat))*withsub_err(1);
     
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
    subplot(2,2,b) %figure
    plottitle=strrep(roi(r).name,'_','\_');
    % condnames={'M1','M2','M3','M4','S1','S2','S3','S4'};
    %condnames={'MF','MR','SF','SM'};
    condnames={'Massed','Spaced'}
    %addpath('/space/raid/home/dara/matlab')
    hold on
%     errorbar(meanmat,stdmat,'LineWidth',1)
%     plot(meanmat,'LineWidth',2)
    % barerror(meanmat,stdmat,0.9,'k',{'r';'g';'b'})
    
   % bar(meanmat,stdmat,0.9,'k',{'r';'g';'b'})
    % subplot(1,2,1);
    %m=bar(meanmat);grey=[0 0.7 0];
    %set(m,'FaceColor',grey)
    %set(m,'Linewidth',3);
    %hold on
    %errorbar(meanmat,stdmat,'.k','LineWidth',3)
    %barerror(meanmat,stdmat,0.9,'k',{'r';'g';'b'})
%     barerror(meanmat,stdmat,0.9,'k',{[91 178 30]./255;[250 140 13]./255;'b';'b'}) 
%     set(gca,'XTick',[1:2])
%     set(gca,'Xticklabel',condnames);
%     set(gca,'FontSize',20)
%     %set(gca,'fontname','Arial')
%     set(gcf,'Color',[1 1 1]) % set background to white
%     title(plottitle)
%     legend('Forgotten','Remembered');
%     %xlabel('Condition')
%     % xlabel(['F = ' num2str(F1) '; P = ' num2str(P1)]);
%     ylabel('Summed activation')
%     % text (1,1,['F = ' num2str(F1) '; P = ' num2str(P1)]);
%     hold off
%     orient tall
%     %set(get(m,'parent'), 'position',[0.153957 0.11 0.751043 0.815]);
%     print('-dpsc2','-painters','-append',['plots_2bin'])
%     
%     
    
     %%%%%repetition priming;
     y=roi(r).all; % y(3,5)=0.27; y(6,13)=0.3;
    RS=[y(:,1)-mean(y(:,2:4),2) y(:,5)-mean(y(:,6:8),2) y(:,9)-mean(y(:,10:12),2) y(:,13)-mean(y(:,14:16),2)];
    stats=do_anova2(RS,f1_num,f2_num,fac);
    withsub_err=sqrt(stats{6,4}/size(y,1));
    meanmat=mean(RS);
    meanmat=[meanmat([1:2]); meanmat([3:4])]';
    stdmat=ones(size(meanmat))*withsub_err(1);
    
    % subplot(1,2,2);
%     m=bar(meanmat);grey=[0 0.7 0];
%     set(m,'FaceColor',grey)
%     set(m,'Linewidth',3);
%     hold on
%     errorbar(meanmat,stdmat,'.k','LineWidth',3)
    barerror(meanmat,stdmat,0.9,'k',{[91 178 30]./255;[250 140 13]./255;'b';'b'}) 
    set(gca,'XTick',[1:2])
    set(gca,'Xticklabel',condnames);
    set(gca,'FontSize',20)
    %set(gca,'fontname','Arial')
    set(gcf,'Color',[1 1 1]) % set background to white
    title(plottitle)
    % legend('Forget','Remember');
    %xlabel('Condition')
    % xlabel(['F = ' num2str(F1) '; P = ' num2str(P1)]);
    ylabel('Neural repetition suppression')
    
    % text (1,1,['F = ' num2str(F1) '; P = ' num2str(P1)]);
    hold off
    orient tall
    %set(get(m,'parent'), 'position',[0.153957 0.11 0.751043 0.815]);
    print('-dpsc2','-painters','-append',['plots_2bin'])
      
    
end

cd(basedir);
