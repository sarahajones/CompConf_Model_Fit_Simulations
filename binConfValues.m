function ordinalBins = binConfValues (Data)

numBins = 10;
binsBelow = 0;
binningGroup = Data.ModelType;

binningSep = 'True';
enforceZeroPoint = 'True';

intVar = Data.Confidence;


if strcmp(binningSep, 'True')
    
    for i = 1 : length(unique(Data.ModelType))
        currentBin = Data.ModelType(i); 
        
        if strcmp(enforceZeroPoint, 'True') %if true 
            
        % Find the proportion of trials below centerPoint so that this can be
        % imposed as a boundary
            trialsBelow = sum(intVar(Data.ModelType == currentBin) < 0.5);
            propBelow = trialsBelow / sum(Data.ModelType == currentBin);
            binsAbove = numBins - binsBelow;
            pDivisionsBelow = linspace(0, propBelow, (binsBelow +1)); % linearly spaced  
            pDivisionsAbove = linspace(propBelow, 1, (binsAbove +1));
            
            pDivisions = [pDivisionsBelow, pDivisionsAbove(2 : end)];
       
        
            breaks{iBinGroup} = ...
                quantile(contVar(binningGroup == currentBin), pDivisions);
            %quantile takes numbers as proportions and specifies edges in
            %variable terms, back from confidence to probability

            % After which category does the centerPoint fall?
            indecisionPoint{currentBin} = bins{binsBelow};
        
        
        else

            % In this case we can just divide up the entirity of the data using the 
            % desired number of quantiles.
            quantileSize = 1 / Settings.NumBins;
            pDivisions = 0 : quantileSize : 1;


            breaks{iBinGroup} = ...
                quantile(contVar(binningGroup == currentBin), pDivisions);


        end
    
    end
end


end


