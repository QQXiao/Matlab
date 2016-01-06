
% load /windows/D/data/space_learning/scripts/pattern_results.mat
subs=[1:22];
%outliers=[3 8,13,18,22];%[2,3,6,11];
%outliers=[3 8,12 13,16,18,19 22];%[2,3,6,11];
%subs=setxor(subs,outliers);



%% remove the outlier of the run, fusiform
% if roi==1;
%     pattern_coef(12,3,:)=mean(pattern_coef(12,[1,2],:),2);
%     pattern_coef(16,[1:2],:)=pattern_coef(16,[3 3],:);
%     pattern_coef(19,1,:)=mean(pattern_coef(19,[2,3],:),2);       
% end
for i=1:length(allroi)
%figure
pattern_coef=allroi{i};
x=squeeze(mean(pattern_coef,2)); %% control
z=[mean(x(:,1:3:end),2) mean(x(:,2:3:end),2) mean(x(:,3:3:end),2)];
y=pattern_coef(subs,:,:);
y=squeeze(mean(y,2));
y_1=y(:,[2:3 5:6 8:9]) ;
y_all=y(:,[1 4 7]);
y_1mean=mean(y_1);
y_allmean=mean(y_all);

% interval effect 
MSEABC=do_anova2(y_1,3,2,{'mem','interval'});
withsub_err=sqrt(MSEABC{4,4}/size(y,1));

% overall
[stats F1 P1]=do_anova1(y_all)
all_err=sqrt(stats/size(y_all,1));

meanmat=[reshape(mean(y),3,3) mean(z)'];
stdmat=[[all_err all_err all_err];withsub_err*ones(2,3)];
stdmat=[stdmat (std(z)/sqrt(22))'];


    figure
    % plottitle=strrep(roi(r).name,'_','\_');
    % condnames={'M1','M2','M3','M4','S1','S2','S3','S4'};
    condnames={'Overall','One interval','Two interval'};
    hold on
    
    barerror(meanmat,stdmat,0.9,'k',{'r';'g';'b';'y'})
    % m=bar(meanmat);grey=[0 0.7 0];
    %set(m,'FaceColor',grey)
    %set(m,'Linewidth',3);
    %errorbar(meanmat,withsub_err,'.k','LineWidth',3)
    set(gca,'XTick',[1:3])
    set(gca,'Xticklabel',condnames);
    set(gca,'FontSize',20)
    %set(gca,'fontname','Arial')
    set(gcf,'Color',[1 1 1]) % set background to white
    set(gca,'ylim',[0.3 0.61])
    title(roi_name(i))
    % legend('Recalled','Recognized','Forgotten','Baseline');
    %xlabel('Condition')
    xlabel(['F = ' num2str(F1) '; P = ' num2str(P1)]);
    ylabel('Mean Correlation')
    
    % text (1,1,['F = ' num2str(F1) '; P = ' num2str(P1)]);
    hold off
    orient tall
    set(gcf,'position',[469 395 811 525]);
    %print('-dpsc2','-painters','-append',['plots_2bin'])
%lls cd(basedir);    
end
