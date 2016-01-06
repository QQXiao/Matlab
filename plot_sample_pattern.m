a=all{34,3};

tit={'Recall','Recogn','Forgot'}

figure;
for i=1:3
subplot(1,3,i)
scatter(a(:,i*3-2),a(:,i*3),500,'.r');
[r p]=corrcoef(a(:,i*3-2),a(:,i*3));
set(gca,'fontsize',15);
set(gca,'xlim',[-100 500]);
set(gca,'ylim',[-100 500]);
ylabel('3th Rep');
xlabel('1st Rep');
text(0,450,sprintf('r=%0.4f;p=%0.4f',r(1,2), p(1,2)))
Title(tit{i});
line([-90 490],[-90 490],'linewidth',2,'color','k');
end
