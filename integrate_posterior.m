function [integrated_pp] = integrate_posterior(pp,a)
%This function integrates the posterior probabilities

rows=size(pp,1);
columns=size(pp,2);
integrated_pp=zeros(rows,columns);

for i=1:rows
    if(i==1)
        integrated_pp(i,1)=0.5;
        integrated_pp(i,2)=0.5;
    end
 integrated_pp(i,1)=a*pp(i-1,1)+(1-a)*pp(i-1,1);
 integrated_pp(i,2)=1-integrated_pp(i,1);

end
   
end

