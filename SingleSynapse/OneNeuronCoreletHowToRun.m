%%%%%%%%%%%%%%%%%%%
% Set up corelets %
%%%%%%%%%%%%%%%%%%%

corelet_init(); report(1); % always the first line - sets up environment and sets level of output

oneNeuronCorelet = OneNeuronCorelet();
oneNeuronCorelet.inputs(1).setExternalInput('simpleInput'); % recognize and give a name to the input connector
oneNeuronCorelet.outputs(1).setExternalOutput('simpleOutput'); % recognize and give a name to the output connector

oneNeuronCorelet.cr_disp; % print info via dispThis()
verified = oneNeuronCorelet.verify(0); % verify via verifyThis() - 0 to suppress output

oneNeuronCorelet.addMetadata(); report(2);
fileNames = oneNeuronCorelet.genFilenames('oneNeuronCorelet', 'Test'); % output file names within the test directory
oneNeuronCorelet.makeModel(fileNames); % make a model and save the files

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Info needed by Compass (NSCS) to perform sim %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numTicks = 100;
config = nscs_config(struct('tickCount', numTicks)); % ticks configuration
config.setSpikesOutputFile('oneNeuronCoreletOutputSpikes', 'TEXT'); % set the output spikes file
config.saveAs(fileNames.configLocal); % save the configuration file to the local folder

spikes = zeros(1, numTicks, 'uint8'); % a vector full of zeros for the input spikes
spikes(1:2:numTicks) = 1; % set every other spike to 1
spikeTable.spikes = spikes; % make spike table
spikeTable.connector = oneNeuronCorelet.inputs(1); % hook up the connection to the corelet input
inputSpikeFileName = ['Test', filesep, 'oneNeuronCoreletInputSpikes.sfti'] % input spikes file
create_spike_file(inputSpikeFileName, spikeTable); % save the input spikes file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run simulation on Compass (NSCS) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ispc
    cmd = ['SET OMP_NUM_THREADS=1 & nscsMP', fileNames.configLocal, ' ', fileNames.modelLocal, ' ', inputSpikeFileName, ';'];
elseif isunix && ~ismac
    cmd = ['export OMP_NUM_THREADS=1; nscs ', fileNames.configLocal, ' ', fileNames.modelLocal, ' ', inputSpikeFileName, ';'];
else
    disp('No NSCS version for mac')
    return;
end

system(cmd);
movefile('oneNeuronCoreletOutputSpikes0.sfto', 'Test');

%%%%%%%%%%%%%%%%%%%
% Display results %
%%%%%%%%%%%%%%%%%%%

outputSpikeFileName = ['Test', filesep, 'oneNeuronCoreletOutputSpikes0.sfto'];
read_spike_file(outputSpikeFileName, fileNames.outputMapLocal);
