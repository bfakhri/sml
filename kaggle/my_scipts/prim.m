% Load Prelim
firstseg = load('../eeg/test_1/1_1.mat')

tic
Fs = firstseg.dataStruct.iEEGsamplingRate;            % Sampling frequency
T = 1/Fs;                                             % Sampling period
L = firstseg.dataStruct.nSamplesSegment;              % Length of signal
t = (0:L-1)*T;                                        % Time vector
Y = fft(firstseg.dataStruct.data(:,1));
toc

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
plot(f,P1)
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')