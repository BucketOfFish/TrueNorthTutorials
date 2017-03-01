classdef twoNeuronCorelet < corelet

properties
end

methods

    function obj = twoNeuronCorelet()

        obj.name = 'twoNeuronCorelet';
        obj.setUpNeuronTypes();
        obj.setUpCores(); % see function below - sets up cores, the type of each axon and neuron, and which synapses are active
        obj.setUpIO();

    end

    function setUpNeuronTypes(obj)

        obj.addNeuronTypes(2, 'linear'); % linear neuron type from the library - here we use the number 2 to add two linear neurons

        obj.neuron(1).S = [1 1 0 0]; % first two axon types have weights of 1
        obj.neuron(1).sigma = [1 -1 1 1]; % second axon type is negative
        obj.neuron(1).alpha = 1; % threshold is 1
        obj.neuron(1).beta = 0; % negative threshold - potential bottoms out at 0
        obj.neuron(1).lmda = 0; % no leakage current
        obj.neuron(1).sigma_l = -1; % sign of the leak (irrelevant here)

        obj.neuron(2).S = [2 0 0 0]; % axon type 0 has a weight of 2, and the rest are 0 (note that array numbering here differs from Matlab) - four types of axons per neuron
        obj.neuron(2).sigma = [1 1 1 1]; % signs for each axon weight
        obj.neuron(2).alpha = 4; % threshold is 4
        obj.neuron(2).beta = 0; % negative threshold - potential bottoms out at 0
        obj.neuron(2).lmda = 1; % leakage current
        obj.neuron(2).sigma_l = -1; % sign of the leak (irrelevant here)

    end

    function setUpCores(obj)

        obj.addCores(1); % this corelet only has one core - CPE instantiates a core and assigns it an ID

        axonTypes(1:256) = 0; % different axon types treat input spikes differently - '0' corresponds to an entry in the S array
        axonTypes(2) = 1; % the negative weight axon
        crossbar = zeros(256, 256, 'uint8'); % only four synapses are on
        crossbar(1, 1) = 1; % this synapse is on
        crossbar(2, 1) = 1; % this synapse is on
        crossbar(3, 2) = 1; % this synapse is on
        crossbar(3, 3) = 1; % this synapse is on

        neuronTypes(1) = obj.neuron(1).nID; % neuronTypes is a 256-length array, with what each neuron is - the ID is a global neuron type identifier
        neuronTypes(2) = obj.neuron(2).nID;
        neuronTypes(3) = obj.neuron(1).nID; % third neuron is neuron type 1 again
        neuronTypes(4:256) = obj.neuron(1).nID * 0; % set other neuron types to nID 0 - can't just set it to an integer

        obj.core(1).setW_ij(crossbar);
        obj.core(1).setAllG_i(axonTypes);
        obj.core(1).setAllNeurons(neuronTypes);

	PRINT_XBAR = 1;
	if PRINT_XBAR
	    fprintf('\n\n----------------------------------------------------------------------------------\n\n\n');
	    fprintf('Subsection of the xbar structure:\n');
	    for i=1:50
	        for j=1:50
	            if j == 1
	                fprintf('%d ', axonTypes( 1,i ))
	            end
                    if (obj.core(1).w_ij(i,j) == 1)
	                fprintf('# ')
	            else
	                fprintf('. ')
	            end
	        end
	        fprintf('\n');
	    end
	    fprintf('\n\n----------------------------------------------------------------------------------\n\n\n');
	end 

    end

    function setUpIO(obj)

        numPins = 1; % 1 input, 1 output

        obj.inputs(1) = connector(numPins, 'input'); % create input connector with 1 pin
        targetCoreIds = obj.core(1).coreID; % target is core 1
        targetAxons = 1; % target is axon 1
        obj.inputs(1).wireTgtCores(targetCoreIds, targetAxons); % input connector gets routed to core 1, axon 1

        obj.outputs(1) = connector(numPins, 'output'); % create output connector with 1 pin
        sourceCoreIds = obj.core(1).coreID; % coming from core 1
        sourceNeurons = 3; % coming from neuron 3
        obj.outputs(1).wireSrcCores(sourceCoreIds, sourceNeurons); % output connector is connected to core 1, neuron 3

        obj.core(1).setDisconnected(4 : 256); % disconnect the unused neurons on core 1

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Hooking up neural connections %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	srcNeurons(1) = 1; % neurons
	destAxons(1) = 3; % send to axons
	destCores(1) = obj.core(1).coreID; % on core 1 (so core is hooked up to itself)

	srcNeurons(2) = 2; % neurons
	destAxons(2) = 2; % send to axons
	destCores(2) = obj.core(1).coreID; % on core 1 (so core is hooked up to itself)

	obj.core(1).setDest(srcNeurons, destCores, destAxons);

    end

    function dispThis(obj, depth)

        fprintf('Corelet %s: \n', obj.name); % display corelet info

    end

    function verified = verifyThis(obj, depth)

        verified = true; % check if parameters are correct - trivial in this case

    end

end

end
