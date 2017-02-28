%%%%%%%%%%%%%%%%%%%
% Set up corelets %
%%%%%%%%%%%%%%%%%%%

corelet_init(); report(1); % always the first line - sets up environment and sets level of output

oneNeuronCorelet = OneNeuronCorelet(); % make corelet
oneNeuronCorelet.inputs(1).setExternalInput('simpleInput'); % recognize and give a name to the input connector
oneNeuronCorelet.outputs(1).setExternalOutput('simpleOutput'); % recognize and give a name to the output connector

oneNeuronCorelet.cr_disp; % print info via dispThis()
verified = oneNeuronCorelet.verify(0); % verify via verifyThis() - 0 to suppress output

%%%%%%%%%%%%%%
% Save model %
%%%%%%%%%%%%%%

modelName = 'oneNeuronCorelet'; % base name for the model files
outputFolder = 'Test'; % where the files will be saved

model = makeModel(oneNeuronCorelet, modelName, outputFolder); % create all model files

%%%%%%%%%%%%%%%%%%%%%%%
% Create input spikes %
%%%%%%%%%%%%%%%%%%%%%%%

numTicks = 100;
model.tickCount = numTicks; % optional for model

spikes = zeros(1, numTicks, 'uint8'); % a vector full of zeros for the input spikes
spikes(1:2:numTicks) = 1; % set every other spike to 1
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

% nothing here right now
