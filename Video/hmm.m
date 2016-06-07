classdef hmm
   
    properties
        hmm_features  % number of features in your vector
        hmm_states % number of output states
        hmm_mixes % % don’t think you’re using multiple mixture components, so you can leave this as 1
        hmm_streams % vector containing the number of features in each stream, so if you had a vector of length 50, and wanted the first 35 as stream 1, and the last 15 as stream 2, set this to [35;15].
        hmm_weights % look at the code to see how this is used, but again, it’s the weight of each stream defined in p.hmm_streams, so [weight1;weight2]  
    end
    
    methods
    end
    
end

