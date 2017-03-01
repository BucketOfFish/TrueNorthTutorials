classdef subcorelets < corelet

properties
end

methods

    function obj = subcorelets(numCores)

        obj.name = 'subcorelets';
        childOne = oneNeuronCorelet();
        childTwo = oneNeuronCorelet();
        obj.subcorelets(1) = childOne;
        obj.subcorelets(2) = childTwo;

        parentInput = connector(childOne.inputs(1).csize, 'input'); % make a connector the same size as the child's input
        parentInput.busTo(childOne.inputs(1)); % and send it over
        obj.inputs(1) = parentInput;

        childOne.outputs(1).busTo(childTwo.inputs(1)); % connect children

        parentOutput = connector(childTwo.outputs(1).csize, 'output'); % make a connector the same size as the child's output
        parentOutput.busFrom(childTwo.outputs(1)); % and send it over
        obj.outputs(1) = parentOutput;

    end

    function dispThis(obj, depth)

        fprintf('Corelet %s:\n', obj.name);

    end

    function verified = verifyThis(obj, depth)

        verified = true; % check if parameters are correct - trivial in this case

    end

end

end
