classdef oneNeuronCorelet < corelet

properties
end

methods

    function obj = oneNeuronCorelet()

        obj.name = 'oneNeuronCorelet';
        obj.setUpNeuronTypes();
        obj.setUpCores(); % see function below - sets up cores, the type of each axon and neuron, and which synapses are active
        obj.setUpIO();

    end

    function setUpNeuronTypes(obj)

        obj.addNeuronTypes(1, 'linear'); % linear neuron type from the library - here we use the number 1 to add a single neuron type (1 is not an index) - other types include 'stochastic' and 'linear-integrate-and-fire'
        obj.neuron(1).S = [1 0 0 0]; % axon type 0 has a weight of 1, and the rest are 0 (note that array numbering here differs from Matlab) - four types of axons per neuron
        obj.neuron(1).sigma = [1 1 1 1]; % signs for each axon weight
        obj.neuron(1).alpha = 1; % threshold is 1
        obj.neuron(1).beta = 0; % negative threshold - potential bottoms out at 0
        obj.neuron(1).lmda = 0; % no leakage current
        obj.neuron(1).sigma_l = -1; % sign of the leak (irrelevant here)

    end

    function setUpCores(obj)

        obj.addCores(1); % this corelet only has one core - CPE instantiates a core and assigns it an ID

        axonTypes(1:256) = 0; % different axon types treat input spikes differently - '0' corresponds to an entry in the S array
        crossbar = zeros(256, 256, 'uint8'); % only one synapse is on
        crossbar(1, 1) = 1; % this synapse is on
        neuronTypes(1) = obj.neuron(1).nID; % neuronTypes is a 256-length array, with what each neuron is - the ID is a global neuron type identifier
        neuronTypes(2:256) = obj.neuron(1).nID * 0; % set other neuron types to nID 0 - can't just set it to an integer

        obj.core(1).setW_ij(crossbar);
        obj.core(1).setAllG_i(axonTypes);
        obj.core(1).setAllNeurons(neuronTypes);

    end

    function setUpIO(obj)

        numPins = 1; % 1 input, 1 output

        obj.inputs(1) = connector(numPins, 'input'); % create input connector with 1 pin
        targetCoreIds = obj.core(1).coreID; % target is core 1
        targetAxons = 1; % target is axon 1
        obj.inputs(1).wireTgtCores(targetCoreIds, targetAxons); % input connector gets routed to core 1, axon 1

        obj.outputs(1) = connector(numPins, 'output'); % create output connector with 1 pin
        sourceCoreIds = obj.core(1).coreID; % coming from core 1
        sourceNeurons = 1; % coming from neuron 1
        obj.outputs(1).wireSrcCores(sourceCoreIds, sourceNeurons); % output connector is connected to core 1, neuron 1

        obj.core(1).setDisconnected(2 : 256); % disconnect the unused neurons on core 1

    end

    function dispThis(obj, depth)

        fprintf('Corelet %s: \n', obj.name); % display corelet info

    end

    function verified = verifyThis(obj, depth)

        verified = true; % check if parameters are correct - trivial in this case

    end

end

end
