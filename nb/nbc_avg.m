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
        int_data(i, end) = -1;
    end
end

%% Begins NBC

% Perform 5 trials with random subsets

for trial = 1:5
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

        num_attributes = size(int_data, 2)-1;
        class_prediction = zeros(size(test_data, 1), 1);

        % Split training into positive and negative class arrays
        pos_class = train_data((train_data(:,end) == 1), :);
        neg_class = train_data((train_data(:,end) == -1), :);

        % Calculate Prob of What Class 
        for sample = 1:size(test_data,1)
            pos_prod = 1;
            neg_prod = 1;
            for attr = 2:num_attributes
                pos_prod = pos_prod * (sum(pos_class(:, attr) == test_data(sample, attr))+1)/size(pos_class, 1);
                neg_prod = neg_prod * (sum(neg_class(:, attr) == test_data(sample, attr))+1)/size(neg_class, 1);
            end
            pos_prod = pos_prod * size(pos_class, 1)/train_size; 
            neg_prod = neg_prod * size(neg_class, 1)/train_size; 
            if(pos_prod > neg_prod)
                class_prediction(sample) = 1;
            else
                class_prediction(sample) = -1;
            end    
        end

        % Get accuracy Measure
        score = class_prediction - test_data(:,end);
        scores(trial, subset) = sum(score == 0);
    end
end

results = mean(scores, 1)/size(test_data, 1)
figure 
plot(subsets, results)
