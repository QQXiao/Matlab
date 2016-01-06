
% load /windows/D/data/space_learning/scripts/pattern_results.mat
subs=[1:24];
outliers=[3 8,13,18,22];%[2,3,6,11];
subs=setxor(subs,outliers);

y=pattern_coef(subs,:,:);
y=squeeze(mean(y,2));
y_1=y(:,[2:4 6:8]);
y_all=y(:,[1 5]);
y_1mean=mean(y_1);
y_allmean=mean(y_all);

% interval effect 
MSEABC=do_anova2(y_1,2,3,{'mem','interval'});
withsub_err=sqrt(MSEABC{4,4}/size(y,1));

% overall
do_anova1(y_all)
all_err=sqrt(0.018/size(y_all,1));

meanmat=reshape(mean(y),4,2);
stdmat=[[all_err all_err];withsub_err*ones(3,2)];

    figure
    % plottitle=strrep(roi(r).name,'_','\_');
    % condnames={'M1','M2','M3','M4','S1','S2','S3','S4'};
    condnames={'Overall','One interval','Two interval','Three interval'};
    hold on
    
    barerror(meanmat,stdmat,0.9,'k',{'r';'g';'b'})
    % m=bar(meanmat);grey=[0 0.7 0];
    %set(m,'FaceColor',grey)
    %set(m,'Linewidth',3);
    %errorbar(meanmat,withsub_err,'.k','LineWidth',3)
    set(gca,'XTick',[1:4])
    set(gca,'Xticklabel',condnames);
    set(gca,'FontSize',20)
    %set(gca,'fontname','Arial')
    set(gcf,'Color',[1 1 1]) % set background to white
    %title(plottitle)
    legend('Rememberred','Forgotten');
    %xlabel('Condition')
    % xlabel(['F = ' num2str(F1) '; P = ' num2str(P1)]);
    ylabel('Mean Correlation')
    
    % text (1,1,['F = ' num2str(F1) '; P = ' num2str(P1)]);
    hold off
    orient tall
    %set(get(m,'parent'), 'position',[0.153957 0.11 0.751043 0.815]);
    print('-dpsc2','-painters','-append',['plots_2bin'])
% cd(basedir);    
 