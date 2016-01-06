datadir='/windows/D/data/recall_singletrial/group'
roi_img_dir=fullfile(datadir,'roi','roi','done');
roiplotdir=fullfile(datadir,'roi','plots');
basedir='/windows/D/data/recall_singletrial/group/roi/scripts';
addpath(basedir)

cwd=pwd;
subs=[1:22];

cope_nums=[4:9];
%cd(roi_img_dir)
%roi_files=dir('*.nii.gz');
roi_name={'LIFG','RIFG','LIPL','RIPL','LFUS','RFUS','LITG','RITG',...
          'LdLOC','RdLOC','LvLOC','RvLOC','LMTG','RMTG',...
          'LHIP','RHIP','LAMG','RAMG','LPHG','RPHG','IPLLOC05','LIPLLOC_diff16'};
      
for c=1:length(cope_nums),
    cope_dir=fullfile(datadir,['cope' num2str(cope_nums(c)) '.gfeat'],'cope1.feat');
    cd(cope_dir)
    for r=1:length(roi_name),
        if r>20
            true_psc=load([roi_name{r} '.txt']);
        else
            true_psc=load([roi_name{r} '_atlas' '.txt']);
        end
        roi(r).all(:,c)=true_psc;
        roi(r).name=roi_name{r};
    end
end

%% replace outlier by mean
% roi(3).all(5,2)=0.19 % replace by mean

cd(roiplotdir)
save all_data roi;
%load all_data

fid=fopen('meanresult_summary.txt','w');
fprintf(fid,'ROI\tmemF\tmemP\trepF\trepP\tinterF\tinterP\n');


%for r=1:length(roi_files)

for r=1:22
     
%%% plot
% first, do anova to decide the errorbar
    %addpath('/space/raid2/data/poldrack/cogrev/results')
   f1_num=2; % mem
   f2_num=3; % rep
   fac={'memory','rep'};
    y=roi(r).all;
    y=y(subs,:);
    stats=do_anova2(y,f1_num,f2_num,fac);
    fprintf(fid,'%s\t%0.5f\t%0.5f\t%0.5f\t%0.5f\t%0.5f\t%0.5f\n',roi_name{r},stats{2,5},stats{2,6},stats{3,5},stats{3,6},stats{4,5},stats{4,6});
end
fclose(fid)

%     withsub_err=sqrt(stats{4,4}/size(y,1));
%     
%     meanmat=mean(y);
%     meanmat=[meanmat([1:3]);meanmat(4:6)]';
%     stdmat=ones(size(meanmat))*withsub_err(1);
% 
%     % finally, plot
%     %figure
%     plottitle=strrep(roi(r).name,'_','\_');
%     condnames={'P1','P2','P3'};
%     hold on
%     subplot(2,1,r); 
%     %figure
%     barerror(meanmat,stdmat,0.9,'k',{'r';'g';'b'})
%     set(gca,'XTick',[1:3])
%     set(gca,'Xticklabel',condnames);
%     set(gca,'FontSize',20)
%     %set(gca,'ylim',[0 0.8]);
%     set(gca,'fontname','Arial')
%     set(gcf,'Color',[1 1 1]) % set background to white
%     title(plottitle)
%     legend('Recalled','Forgotten');
%     ylabel('% signal change')
%     
%     hold off
%     orient tall
%     %set(get(m,'parent'), 'position',[0.153957 0.11 0.751043 0.815]);
%     print('-dpsc2','-painters','-append',['plots_2bin'])

cd(basedir);
