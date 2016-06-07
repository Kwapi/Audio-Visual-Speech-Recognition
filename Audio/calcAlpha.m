function [ a ] = calcAlpha( soundPower, noisePower, targetDb )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
a = sqrt(soundPower / noisePower * 10^(-targetDb / 10));

end

