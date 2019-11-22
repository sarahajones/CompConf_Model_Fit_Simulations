function conf = computeConfidence(nTrials,Data, sigma_s, mu_cat1)
%%%% CHECK THIS PLEASE - IS THE Mu-CAT1/2 right??? 
conf = zeros(nTrials, 1);
for iTrial = 1:nTrials  
    
    if Data.ModelType(iTrial, 1) == 0
        
        if Data.Decision(iTrial,1) == 1
           conf(iTrial,1) = (1 / (1 + ((exp(((-2)*(Data.Percept(iTrial, 1))*(mu_cat1))/ (((sigma_s)^2) + ((Data.SigmaX(iTrial,1))^2)))))));
        else 
           conf(iTrial,1) = (1 / (1 + ((exp(((2)*(Data.Percept(iTrial, 1))*(mu_cat1))/ (((sigma_s)^2) + ((Data.SigmaX(iTrial,1) )^2)))))));
        end
    else
        posteriorRatio = (normcdf(0, -Data.Percept(iTrial, 1), Data.SigmaX(iTrial,1) ))/(1 - (normcdf(0, -Data.Percept(iTrial, 1), Data.SigmaX(iTrial,1) )));
       
        if Data.Decision(iTrial,1) == 1
           conf(iTrial,1) = (1 / (1 + (posteriorRatio)^-1)); 
        else
           conf(iTrial,1) = (1 / (1 + (posteriorRatio)));
        end
        
         %if conf(iTrial,1) < 0.5 
              %error('Code not functioning as expected')
         %end

    end
end      
end