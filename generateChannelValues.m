clear; clc;
%% Rician Fading Channel

ricianC = comm.RicianChannel();
ricianC.KFactor = 3;                % Assume K = 3 for a ""rural"" environment
ricianC.SampleRate = 1;             % Sample at 1 sample per second
ricianC.NumSamples = 5000;          % Need 5000 samples for 5km of distance
ricianC.NormalizePathGains = false;
ricianC.ChannelFiltering = false;

pathGains = ricianC();
fadingGainsLog = 20*log10(abs(pathGains)); % Convert to dB

%% Free-space Path loss Channel

FSPL = propagationModel("freespace");

txLoc = txsite('CoordinateSystem','cartesian','AntennaPosition',[0;0;2]);

v_pl = zeros(5000,1);

% Calculate path loss at each meter from the transmitter
% Assume the node is moving at approx. 1 m/s
% Each calculated path loss has a corresponding rician fading gain to
%   combine with (rician channel is sampled at 1 samp/sec)
for i = 1:5000
    rxLoc = rxsite('CoordinateSystem','cartesian', 'AntennaPosition',[i;0;2]);
    v_pl(i) = pathloss(FSPL, rxLoc, txLoc);
end

%% Combine/Plot FSPL and Rician fading

% v_pl is a loss; fadingGainsLog is a gain, subtract to combine correctly
adjustedLoss = v_pl - fadingGainsLog;

% Plot the calclauted loss 
figure;
hold on;
plot(adjustedLoss, 'LineWidth', 1.5);
plot(v_pl, 'LineWidth', 1.5);
ylim([0;max(adjustedLoss)+10]);
title("Path loss of a free-space lunar channel with rician fading (K=3)")
ylabel('Path loss [dB]');
xlabel('Distance [m]');
legend('Modeled Channel', 'Ideal Free-space');
hold off;

% Dump values for use in EMANE
writematrix(adjustedLoss,'pathLossValues.csv');
