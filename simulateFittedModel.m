function Data = simulateFittedModel(DataSet, Variance, thresh, Lapse, ppNum, modelNum)
%this function aims to simulate a dataset of trials and corresponding confidence reports 
%using the best fits of a model as drawn from simulateFittedDataStruct
%the funciton iterates through nTrials of a simulated experiment using the
%best parameter fits for Variance and Lapse Rates. 
%This dataset is passed back to simulateFittedDataStruct and added to a
%cell array
%the funciton can be looped to iterate throough multiple models as required
%for comparison. 
%% PARAMETER INPUTS 

Data.nTrials = 10000; % number of trials simulated (matches behavioural test blocks, 630x4sessions)

%properties for circle statistics 
mu_cat1 = (15/16).*(pi);
mu_cat2 = (17/16).*(pi);

if ppNum > 4
    kappa_s = 20; % 7 for first 4, 20 thereafter 
else
    kappa_s = 7;%%kappa (concentration parameter, needs to be convereted for derivations to sigma)
end

Data.KappaS = kappa_s;
sigma_s = sqrt(1/Data.KappaS);
prior = 0.5; %assume neutral prior for symmetry of decisions
contrasts = [0.1, 0.2, 0.3, 0.4, 0.8]; %external noise (matches final expCode)

sigma_X = sqrt(Variance); %standard deviation 


%% DATA STRUCTURE
%create dataStruct with stimulus properties and trial info

%split an ABBA pattern, here A is 1 Gabor, and 
%matches with actaul ppData and ABBA exposure 
if DataSet.P(ppNum).Data.numGabors(1,1) == 1 
    for iTrial = 1:Data.nTrials
        if iTrial < 2500
            Data.BlockType(iTrial, 1) = 0;
            Data.numGabors(iTrial, 1)= 1;
        elseif iTrial > 7500 
            Data.BlockType(iTrial, 1) = 0;
            Data.numGabors(iTrial, 1) = 1;
        else
            Data.BlockType(iTrial, 1) = 1;
            Data.numGabors(iTrial, 1) = 2;
        end
    end
else
      for iTrial = 1:Data.nTrials
        if iTrial < 7500
            Data.BlockType(iTrial, 1) = 1;
            Data.numGabors(iTrial, 1)= 2;
        elseif iTrial > 2500 
            Data.BlockType(iTrial, 1) = 1;
            Data.numGabors(iTrial, 1) = 2;
        else
            Data.BlockType(iTrial, 1) = 0;
            Data.numGabors(iTrial, 1) = 1;
        end
      end
    
end

Data.ModelFit = modelNum;%what model are the parameters being drawn from
%set two model types, 0 is Bayes, 1 is Alt. 
%this is setting up what way confidence reports are calculated later. 
for iTrial = 1:Data.nTrials
if Data.ModelFit == 1
    if Data.BlockType(iTrial,1) == 1
        Data.ModelType(iTrial,1) = 1; %alternative for 2 gabors
    else
        Data.ModelType(iTrial,1) = 0; %normative for 1 gabor
    end
    
elseif Data.ModelFit == 2
    Data.ModelType(iTrial,1) = 0; %always normative
    
elseif Data.ModelFit == 3
     if Data.BlockType(iTrial,1) == 1
        Data.ModelType(iTrial,1) = 0; %normative for 2 gabors
    else
        Data.ModelType(iTrial,1) = 1; %alternative for one
     end
     
elseif Data.ModelFit == 4
    Data.ModelType(iTrial,1) = 1; %always alternative 
    
end
end

%label four potential model fits within data struct
if Data.ModelFit ==1
 Data.model  = 'normativeGenerative'; %easy being Rule, hard being BAyes
elseif Data.ModelFit == 2
 Data.model =  'normativeGenerativeAlways'; %always BAyes
elseif Data.ModelFit == 3 
 Data.model = 'alternativeGenerative' ; %easy as BAyes, hard being rule
elseif Data.ModelFit == 4
 Data.model = 'alternativeGenerativeAlways';%always rule based
end

%% ORIENTATION STIMULUS VALUES PER CATEGORY
%set two target categories randomly across nTrials, indepenent of model
%type
Data.Target =  logical(randi([0 1], Data.nTrials, 1)); %the category that should be targetted (correct cat) 0 = cat 1, 1 = cat 2

Data.Orientation = produceOrientations(Data.nTrials, mu_cat1, mu_cat2, Data.KappaS, Data);

%check on orientations
%figure
%hist (Data.Orientation, 50)

%% NOISE TO GAIN MEASURE X (PERCEPT)
%apply noise to the orientation to gain percept value
%should this be adjusted for noncardinal orientations (Adler & Ma
%paper)??? DO THIS LATER 


Data.ContrastLevel = zeros(Data.nTrials,1);

for iTrial = 1:Data.nTrials
    indexofInterest = randperm(5,1);
    Data.ContrastLevel(iTrial,1) = contrasts(indexofInterest);
    
    if Data.numGabors(iTrial) == 1
       Data.SigmaX(iTrial,1) = sigma_X(indexofInterest, 1);
       Data.SigmaX(iTrial,1);
    else
       Data.SigmaX(iTrial,1) = sigma_X(indexofInterest, 2);
       Data.SigmaX(iTrial,1);
    end
    
end

 Data.Percept = producePercept(Data.nTrials, Data);


% If any percepts are outside the range [-pi pi] then move them back in (any
% grating angle can be mapped into this range)
Data.Percept = vS_mapBackInRange(Data.Percept, 0, 2*pi);


%% COMPUTE DECISION / RESPONSE
%BASED ON FULL LOGLIKLIHOOD RATIO 
%But simple rule amounts to the same thing as:
%the categories are symmetrical and prior is 0.5.


Data.Decision = giveResp(Data.nTrials, Data, mu_cat2, mu_cat1, prior);

%check percentage correct

for i = 1:Data.nTrials
    if Data.Target(i,1) == Data.Decision(i,1)
        Data.Correct(i,1) = 1;
    else
        Data.Correct(i,1) = 0;
    end    
end  

% check on decision accuracy
sum(Data.Correct, 'all')

%% CONFIDENCE
%calculate confidence value for each trail based on model type and decision
%made by the observer based on their percept. 

Data.Confidence = computeConfidence(Data.nTrials, Data,  sigma_s, mu_cat1);


%% prep DATA.STRUCT for binning

thresh = sort(thresh); %sort the thresholds to ensure they are monotonically increasing
%(required for discretize)
Data.thresh = thresh; %save thresholds to Data
Data.binnedConfidence = discretize(Data.Confidence, thresh); %bin data using fitteed thresholds as edges
%binned confidence is fit to individual bins that are best fit for the pp
%under the current model.


%% insert Lapse rate
%lapse on a certain number of trials as fitted by the model fit for this
%participant. Lapse rate 
Data.Lapse = Lapse; %save lapse rate to Data
 for iTrial = 1:Data.nTrials
     if rand(1,1) < Data.Lapse
     Data.binnedLapseConfidence(iTrial, 1) = randi(10, 1,1); 
     end
 end
end