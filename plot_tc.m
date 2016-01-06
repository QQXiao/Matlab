load ../plots/timecourse.mat
timecourse(timecourse>0.5 | timecourse < -0.5)=NaN;
tc_sub=squeeze(nanmean(timecourse,2)); % meanacross runs
% tc_sub=tc_sub(:,2:end-1,:); % remove the two fillers
tc_mean=squeeze(mean(tc_sub,1)); % mean cross subjects.


cond={'MR','MF','SR','SF'};
% plot 1:4 massed
for i=1:length(cond);
x=tc_mean([2:5]+(i-1)*4,:);
subplot(2,2,i);
plot([1:11],x(1,:),'rs','linewidth',2)
end