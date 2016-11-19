%% Clear Console and Variables
clc;
clear;

%% Get list of files in directory
files_1 = dir('../eeg/train_1/');
files_1 = files_1(3:end);
files_2 = dir('../eeg/train_2/')
files_2 = files_2(3:end);
files_3 = dir('../eeg/train_3/')
files_3 = files_3(3:end);



%% Load Files
for f=1:100
    temp = load(strcat('../eeg/train_1/', files_1(f).name));
    data_1(f,:,:) = temp.dataStruct.data;
    spl = strsplit(files_1(f).name, '_');
    spl = strsplit(char(spl(end)), '.');
    data_1_label(f) = (char(spl(1)) == '1');
end

%% Machine Learning
%[X,T] = simpleseries_dataset;
net = layrecnet(1:2,10);
[Xs,Xi,Ai,Ts] = preparets(net, num2cell(data_1(:, :, 1)), repmat(data_1_label, 100, 1));
net = train(net,Xs,Ts,Xi,Ai);
view(net)
Y = net(Xs,Xi,Ai);
