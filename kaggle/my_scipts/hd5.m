%% Takes EEG Data and turns it into pictoral data (sortof)
%% Clear Console and Variables
clc;
clear;

NUM_DIRS = 6;
NUM_CHANNELS = 16;
data_dirs = {'../eeg/train_1/', '../eeg/train_2/', '../eeg/train_3/', '../eeg/test_1/', '../eeg/test_2/', '../eeg/test_3/'};

%% Get list of files in directory
for d=1:NUM_DIRS
    temp = dir(data_dirs{d});    
    all_files{d} = temp(3:end);
end


train_data = zeros(1, 16); 
test_data = zeros(1, 16); 
train_labels = 0; 
test_filenames = {};

%% Main Loop
for directory=1:NUM_DIRS
    for f=1:size(all_files{directory}, 1)
        % Get Label
        spl = strsplit(all_files{directory}(f).name, '_');
        spl = strsplit(char(spl(end)), '.');
        
        % Generate Label File
        if(directory < 4)
            train_labels = [train_labels; (char(spl(1)) == '1')];
        end
        test_filenames ={test_filenames; all_files{directory}(f).name};
        
        
        % Get data
        temp = load(strcat(data_dirs{directory}, all_files{directory}(f).name));
        all_files{directory}(f).name;
        f/size(all_files{directory}, 1)*100/(NUM_DIRS - (directory-1));
        fprintf('%f of %d/%d\n', f/size(all_files{directory}, 1)*100, directory, NUM_DIRS);

        temp.dataStruct.data;
        % Get fft of all channels
        for chan=1:NUM_CHANNELS
            Fs = temp.dataStruct.iEEGsamplingRate;            % Sampling frequency
            T = 1/Fs;                                             % Sampling period
            L = temp.dataStruct.nSamplesSegment;              % Length of signal
            t = (0:L-1)*T;                                        % Time vector
            FFT = fft(temp.dataStruct.data(:, chan));    
            P2 = abs(FFT/L);
            P1 = P2(1:L/2+1);
            P1(2:end-1) = 2*P1(2:end-1);
            freq = Fs*(0:(L/2))/L;
            [val, idx] = max(P1);

            %FFTs(f, chan, :) = P1; 
            fft_max_vec(chan) = freq(idx); 
        end
        if(directory < 4)
            train_data= [train_data; fft_max_vec*255/max(fft_max_vec)];
        else
            test_data= [train_data; fft_max_vec*255/max(fft_max_vec)];
        end
    end
end

train_data(isnan(train_data)) = 0; 
test_data(isnan(test_data)) = 0; 

save('train_data.mat', 'train_data');
save('test_data.mat', 'test_data'); 
save('train_labels.mat', 'train_labels'); 
