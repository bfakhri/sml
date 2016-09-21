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

% Convert 2's and 4's to 0 and +1
for i = 1:size(int_data, 1)
    if(int_data(i, end) == 2)
        int_data(i, end) = 1;
    else
        int_data(i, end) = 0;
    end
end

%% Begins LR

eta = 0.001;
epsilon = 0.01;

% Perform 5 trials with random subsets

for trial = 1
    subsets = [.01 .02 .03 .125 .625 1];
    % Split data into train and test sets
    num_entries = size(int_data, 1);
    train_size = floor(2/3*num_entries);
    test_size = num_entries - train_size; 
    rnd_list = randperm(num_entries); 
    for subset = 1:6
        % 2/3 of data goes to training set and the other 1/3 to the test set
        new_train_size = floor(train_size*subsets(subset));
        train_data = int_data(rnd_list(1:new_train_size), :);
        test_data = int_data(rnd_list(train_size+1:end), :);

        num_attributes = size(int_data, 2)-2;
        class_prediction = zeros(size(test_data, 1), 1);

        clear weights;
        clear x_attrs;
        clear y_labels;
        clear x_attrs_test;
        weights = zeros(num_attributes+1, 1); 
        y_labels = train_data(:,end); 
        x_attrs(:,1) = ones(size(train_data, 1), 1); 
        x_attrs_test(:,1) = ones(size(test_data, 1), 1); 
        x_attrs(:,2:size(train_data(:,2:end-1),2)+1) = train_data(:,2:end-1); 
        x_attrs_test(:,2:size(test_data(:,2:end-1),2)+1) = test_data(:,2:end-1);
        diff = inf;
        while diff > epsilon
            old_weights = weights;
            for j = 1:size(weights,1)
                summer = 0;
                for n = 1:size(train_data, 1)
                    summer = summer + x_attrs(n, j)*(y_labels(n) -logsig(weights'*x_attrs(n,:)'));
                end
                weights(j) = weights(j) + eta*summer;
            end
            diff = norm(old_weights - weights);
        end
        
        for n = 1:size(test_data, 1)
            prob_pos(n) = logsig(weights'*x_attrs_test(n,:)');
        end
        results = prob_pos > 0.5;
        score = results' == test_data(:,end);
        scores(trial,subset) = sum(score);
    end
end

results = mean(scores, 1)/size(test_data, 1)
figure 
plot(subsets, results)

