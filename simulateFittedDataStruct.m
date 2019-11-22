function Data = simulateFittedDataStruct(DataSet)
load('BehaviouralDataSet_Analysed.mat');

DataStore = cell(4,1);

for jModel = 1:4
    for iParticipant = 1:13
        ppNum = iParticipant;
        modelNum = jModel;
        Variance  = DataSet.P(iParticipant).Models(jModel).BestFit.Params.Variance;
        thresh = DataSet.P(iParticipant).Models(jModel).BestFit.Params.thresh;
        Lapse = DataSet.P(iParticipant).Models(jModel).BestFit.Params.Lapse;
        DataSetSim.P(iParticipant).Data = simulateFittedModel(DataSet, Variance, thresh, Lapse, ppNum, modelNum);
    end
    
    DataStore{jModel, 1} = DataSetSim;
end
filename = 'DataStore.mat';
 save(filename);
load('DataStore.mat');
end
