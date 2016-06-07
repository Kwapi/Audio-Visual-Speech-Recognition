p = hmm;

p.hmm_features = 227;
p.hmm_states = 10;
p.hmm_mixes = 1;
p.hmm_streams = [2,225];
p.hmm_weights = [0.5,0.5];

writeprotoTT(p,'proto.txt','MFCC');
