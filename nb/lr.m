% Ensure no conflicts
clc;
clear;


%% Gets data
% Opens the Data Set File
ds_fid = fopen('ds.txt');

% Gets data from data set file and strips invalid entries
data = [];
str = fgetl(ds_fid);
data = strsplit(str, ','); 
while ischar(str)
    str = fgetl(ds_fid);
    if(ischar(str) && isempty(findstr(str, '?')))
        data = [data; strsplit(str, ',')];
    end
end

% Close the data set file
fclose(ds_fid);

% Convert from cells to integers
int_data = zeros(size(data));
for i = 1:numel(data)
    int_data(i) = str2num(char(data(i)));
end

% Convert 2's and 4's to -1 and +1
for i = 1:size(int_data, 1)
    if(int_data(i, end) == 2)
        int_data(i, end) = 1;
    else
        int_data(i, end) = 0;
    end
end

%% Begins LR

% Perform 5 trials with random subsets

for trial = 1
    subsets = [.01 .02 .03 .125 .625 1];
    % Split data into train and test sets
    num_entries = size(int_data, 1);
    train_size = floor(2/3*num_entries);
    test_size = num_entries - train_size; 
    rnd_list = randperm(num_entries); 
    for subset = 6
        % 2/3 of data goes to training set and the other 1/3 to the test set
        new_train_size = floor(train_size*subsets(subset));
        train_data = int_data(rnd_list(1:new_train_size), :);
        test_data = int_data(rnd_list(train_size+1:end), :);

        num_attributes = size(int_data, 2)-2;
        class_prediction = zeros(size(test_data, 1), 1);

        weights = zeros(num_attributes, 1); 
        y_labels = train_data(:,end); 
        x_attrs = train_data(:,2:end-1); 
        for iter = 1:100
            p = zeros(size(train_data, 1), 1); 
            for s = 1:size(train_data, 1)
                p(s) = exp(weights'*x_attrs(s,:)')/(1+exp(weights'*x_attrs(s,:)'));
            end
            W = zeros(size(train_data, 1));
            for ij = 1:size(train_data, 1)
                % Is this Right!?!?!?!?!?!?
                W(ij, ij) = p(ij); 
            end
            old_weights = weights;
            X = x_attrs;
            z = X*weights + inv(W)*(y_labels - p);
            weights = inv(X'*W*X)*X'*W*z;
            diff(iter,:) = weights - old_weights;
        end
        
        prob_pos = 1./(1+exp(-weights'*test_data(:,2:end-1)'));
        results = prob_pos > 0.5;
        score = results' == test_data(:,end);
        sum(score)/size(test_data, 1)
    end
end

