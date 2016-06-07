function [ noisySample ] = addNoise(sample, noise, SNR )

%trim the noise file so that it's the same size as the sample
noise = noise(1:length(sample));

noisePower = calcPower(noise);
soundPower = calcPower(sample);

a = calcAlpha(soundPower, noisePower, SNR);

noiseScaled = noise * a;

noisySample = sample + noiseScaled;

end

