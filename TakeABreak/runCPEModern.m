%%%%%%%%%%%%%%%%%%%
% Set up corelets %
%%%%%%%%%%%%%%%%%%%

corelet_init(); report(1); % always the first line - sets up environment and sets level of output

twoNeuronCorelet = twoNeuronCorelet(); % make corelet
twoNeuronCorelet.inputs(1).setExternalInput('simpleInput'); % recognize and give a name to the input connector
twoNeuronCorelet.outputs(1).setExternalOutput('simpleOutput'); % recognize and give a name to the output connector

twoNeuronCorelet.cr_disp; % print info via dispThis()
verified = twoNeuronCorelet.verify(0); % verify via verifyThis() - 0 to suppress output

%%%%%%%%%%%%%%
% Save model %
%%%%%%%%%%%%%%

modelName = 'twoNeuronCorelet'; % base name for the model files
outputFolder = 'Test'; % where the files will be saved

model = makeModel(twoNeuronCorelet, modelName, outputFolder); % create all model files

%%%%%%%%%%%%%%%%%%%%%%%
% Create input spikes %
%%%%%%%%%%%%%%%%%%%%%%%

numTicks = 100;
model.tickCount = numTicks; % optional for model

spikes = ones(1, numTicks, 'uint8'); % a vector full of ones for the input spikes
spikeTable.spikes = spikes; % make spike table

inputConnectors = read_iomap(model.inputMapLocal); % get all model input connectors
spikeTable.connector = inputConnectors(1); % hook up the spikes to the model input

create_spike_file(model.inputFileName, spikeTable); % save the input spikes file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run simulation on Compass (NSCS) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

runMode = 'NSCS'; % run using the simulator.
model = runModel(modelName, outputFolder, runMode, model);

%%%%%%%%%%%%%%%%%%%%%
% Get output spikes %
%%%%%%%%%%%%%%%%%%%%%

spikeTable = read_spike_file(model.outputSpikesLocal, model.outputMapLocal);
outputSpikes = spikeTable.spikesTicks;
outputDelays = spikeTable.spikesDelays;
outputPins = spikeTable.spikesPins;

%%%%%%%%%%%%%%%%%%%
% Display results %
%%%%%%%%%%%%%%%%%%%

% nothing here
