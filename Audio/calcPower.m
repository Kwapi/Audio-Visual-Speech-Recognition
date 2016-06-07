function [ noisePower ] = calcPower( signal )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
noisePower = 0.0;
for n = 1 : length(signal)
    noisePower = noisePower + signal(n)^2;
end
noisePower = noisePower / (length(signal) - 1000);

end

