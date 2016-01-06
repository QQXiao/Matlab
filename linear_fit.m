load ../plots/all_data.mat
a=detrend([1:4],'constant');
x=roi(1).all;
%x=mean(x);
for i=1:size(x,1) % sub
    for k=1:4 % four condition
        data=x(i,[1:4]+(k-1)*4);
        [p s] = polyfit(a,data,1);
        coeff(i,k)=p(1);
        meanact(i,k)=p(2);
    end
end

