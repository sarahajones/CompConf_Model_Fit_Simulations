function orientations =  produceOrientations (nTrials, mu_cat1, mu_cat2, kappa_s, Data)

orientations = zeros(nTrials, 1);

for i = 1:nTrials
    if Data.Target == 0 % if category is one then compute the orientation based on cat 1 mean as follows
        orientations(i,1) =  circ_vmrnd_fixed(mu_cat1, kappa_s, 1); %generate trial orientation .
    else %if cat is 2 (target =1) then compute using cat 2 mean
        orientations(i,1) =  circ_vmrnd_fixed(mu_cat2, kappa_s, 1); %drawn from vonMises distribution.

    end
end

% NORMAL STATS VERSION
% for i = 1:nTrials
%     if Data.Target(i) == 0 % if category is one then compute the orientation based on cat 2 mean as follows
%         orientations(i,1) = ((randn(1, 1) * sigma_X) + mean_cat1);
%     else 
%         orientations(i,1) = ((randn(1, 1) * sigma_X) + mean_cat2);
%     end
% end

   
end


