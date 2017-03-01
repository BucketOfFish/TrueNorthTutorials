classdef daisyChain < corelet

properties

    numCores = 5; % number of cores to daisy chain together

end

methods

    function obj = daisyChain(numCores)

        obj.name = 'daisyChain';
        obj.numCores = numCores;
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

    end

    function setUpCores(obj)

        obj.addCores(obj.numCores); % CPE instantiates the cores and assigns them IDs

        axonTypes(1:256) = 0; % different axon types treat input spikes differently - '0' corresponds to an entry in the S array
        crossbar = zeros(256, 256, 'uint8'); % only one synapses is on
        crossbar(1, 1) = 1; % this synapse is on

        neuronTypes(1) = obj.neuron(1).nID; % neuronTypes is a 256-length array, with what each neuron is - the ID is a global neuron type identifier
        neuronTypes(2:256) = obj.neuron(1).nID * 0; % set other neuron types to nID 0 - can't just set it to an integer

        for coreNum = 1 : obj.numCores
            obj.core(coreNum).setW_ij(crossbar);
            obj.core(coreNum).setAllG_i(axonTypes);
            obj.core(coreNum).setAllNeurons(neuronTypes);
        end

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
        sourceCoreIds = obj.core(obj.numCores).coreID; % coming from last core
        sourceNeurons = 1; % coming from neuron 1
        obj.outputs(1).wireSrcCores(sourceCoreIds, sourceNeurons); % output connector is connected to core 1, neuron 1

        for coreNum = 1 : obj.numCores
            obj.core(coreNum).setDisconnected(2 : 256); % disconnect the unused neurons on each core
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Hooking up neural connections %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        for coreNum = 1 : obj.numCores-1
	    srcNeurons(1) = 1; % neuron 1
	    destAxons(1) = 1; % sends to axon 1
	    destCores(1) = obj.core(coreNum+1).coreID; % on next core
	    obj.core(coreNum).setDest(srcNeurons, destCores, destAxons);
        end

    end

    function dispThis(obj, depth)

        fprintf('Corelet %s: numCores: %d\n', obj.name, obj.numCores);

    end

    function verified = verifyThis(obj, depth)

        verified = true; % check if parameters are correct - trivial in this case

    end

end

end
