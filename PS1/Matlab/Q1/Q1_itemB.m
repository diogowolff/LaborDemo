%% Data processing as done in Mincer (1962)

dataset_1b = dataset(dataset.RACE == 1 & dataset.MARST == 1, :);


% heads_working_index = dataset(dataset.RELATE == 1 & CLASSWKR == 2, 'CBSERIAL');
dataset_1b = dataset_1b(dataset_1b.RELATE == 1 & dataset_1b.INCWAGE > 0, :);

%{It seems that there's a gap on who is interviewed for the sample; of the 40k in this
% subsample (~20% of the original subsample), only 600 have both a woman
% and a man in the same household; it appears that in most cases only the
% household head is interviewed %}



dataset_1b_full_time = dataset_1b(dataset_1b.WKSWORK2 > 3, :);
dataset_1b_not_full_time = dataset_1b(dataset_1b.WKSWORK2 < 4, :);


table_11 = size(unique(dataset_1b_full_time(dataset_1b_full_time.AGE < 35 & dataset_1b_full_time.NCHILD == dataset_1b_full_time.NCHLT5 & ...
    dataset_1b_full_time.EDUCD < 20, {'CBSERIAL', 'SAMPLE'})), 1);

table_12 = size(unique(dataset_1b_full_time(dataset_1b_full_time.AGE < 35 & dataset_1b_full_time.NCHILD == dataset_1b_full_time.NCHLT5 & ...
    dataset_1b_full_time.EDUCD >= 20 & dataset_1b_full_time.EDUCD < 65, {'CBSERIAL', 'SAMPLE'})), 1);

table_13 = size(unique(dataset_1b_full_time(dataset_1b_full_time.AGE < 35 & dataset_1b_full_time.NCHILD == dataset_1b_full_time.NCHLT5 & ...
    dataset_1b_full_time.EDUCD > 64, {'CBSERIAL', 'SAMPLE'})), 1);

table_21 = size(unique(dataset_1b_full_time(dataset_1b_full_time.AGE < 35 & dataset_1b_full_time.NCHLT5 == 0 & ...
    dataset_1b_full_time.EDUCD < 20, {'CBSERIAL', 'SAMPLE'})), 1);

table_22 = size(unique(dataset_1b_full_time(dataset_1b_full_time.AGE < 35 & dataset_1b_full_time.NCHLT5 == 0 & ...
    dataset_1b_full_time.EDUCD >= 20 & dataset_1b_full_time.EDUCD < 65, {'CBSERIAL', 'SAMPLE'})), 1);

table_23 = size(unique(dataset_1b_full_time(dataset_1b_full_time.AGE < 35 & dataset_1b_full_time.NCHLT5 == 0 & ...
    dataset_1b_full_time.EDUCD > 65, {'CBSERIAL', 'SAMPLE'})), 1);

table_31 = size(unique(dataset_1b_full_time(dataset_1b_full_time.AGE > 35 & ...
    dataset_1b_full_time.EDUCD < 20 & dataset_1b_full_time.AGE <= 54, {'CBSERIAL', 'SAMPLE'})), 1);

table_32 = size(unique(dataset_1b_full_time(dataset_1b_full_time.AGE > 35 & ...
    dataset_1b_full_time.EDUCD >= 20 & dataset_1b_full_time.EDUCD < 65 & dataset_1b_full_time.AGE <= 54, {'CBSERIAL', 'SAMPLE'})), 1);

table_33 = size(unique(dataset_1b_full_time(dataset_1b_full_time.AGE > 35 & ...
    dataset_1b_full_time.EDUCD > 64 & dataset_1b_full_time.AGE <= 54, {'CBSERIAL', 'SAMPLE'})), 1);

table_41 = size(unique(dataset_1b_full_time(dataset_1b_full_time.AGE > 55 & ...
    dataset_1b_full_time.EDUCD < 20, {'CBSERIAL', 'SAMPLE'})), 1);

table_42 = size(unique(dataset_1b_full_time(dataset_1b_full_time.AGE > 55 & ...
    dataset_1b_full_time.EDUCD >= 20 & dataset_1b_full_time.EDUCD < 65, {'CBSERIAL', 'SAMPLE'})), 1);

table_43 = size(unique(dataset_1b_full_time(dataset_1b_full_time.AGE > 55 & ...
    dataset_1b_full_time.EDUCD > 64, {'CBSERIAL', 'SAMPLE'})), 1);

table = [table_11, table_12, table_13;
    table_21, table_22, table_23; 
    table_31, table_32, table_33;
    table_41, table_42, table_43];


subtable_11 = size(unique(dataset_1b_not_full_time(dataset_1b_not_full_time.AGE < 35 & dataset_1b_not_full_time.NCHILD == dataset_1b_not_full_time.NCHLT5 & ...
    dataset_1b_not_full_time.EDUCD < 20, {'CBSERIAL', 'SAMPLE'})), 1);

subtable_12 = size(unique(dataset_1b_not_full_time(dataset_1b_not_full_time.AGE < 35 & dataset_1b_not_full_time.NCHILD == dataset_1b_not_full_time.NCHLT5 & ...
    dataset_1b_not_full_time.EDUCD >= 20 & dataset_1b_not_full_time.EDUCD < 65, {'CBSERIAL', 'SAMPLE'})), 1);

subtable_13 = size(unique(dataset_1b_not_full_time(dataset_1b_not_full_time.AGE < 35 & dataset_1b_not_full_time.NCHILD == dataset_1b_not_full_time.NCHLT5 & ...
    dataset_1b_not_full_time.EDUCD > 64, {'CBSERIAL', 'SAMPLE'})), 1);

subtable_21 = size(unique(dataset_1b_not_full_time(dataset_1b_not_full_time.AGE < 35 & dataset_1b_not_full_time.NCHLT5 == 0 & ...
    dataset_1b_not_full_time.EDUCD < 20, {'CBSERIAL', 'SAMPLE'})), 1);

subtable_22 = size(unique(dataset_1b_not_full_time(dataset_1b_not_full_time.AGE < 35 & dataset_1b_not_full_time.NCHLT5 == 0 & ...
    dataset_1b_not_full_time.EDUCD >= 20 & dataset_1b_not_full_time.EDUCD < 65, {'CBSERIAL', 'SAMPLE'})), 1);

subtable_23 = size(unique(dataset_1b_not_full_time(dataset_1b_not_full_time.AGE < 35 & dataset_1b_not_full_time.NCHLT5 == 0 & ...
    dataset_1b_not_full_time.EDUCD > 65, {'CBSERIAL', 'SAMPLE'})), 1);

subtable_31 = size(unique(dataset_1b_not_full_time(dataset_1b_not_full_time.AGE > 35 & ...
    dataset_1b_not_full_time.EDUCD < 20 & dataset_1b_not_full_time.AGE <= 54, {'CBSERIAL', 'SAMPLE'})), 1);

subtable_32 = size(unique(dataset_1b_not_full_time(dataset_1b_not_full_time.AGE > 35 & ...
    dataset_1b_not_full_time.EDUCD >= 20 & dataset_1b_not_full_time.EDUCD < 65 & dataset_1b_not_full_time.AGE <= 54, {'CBSERIAL', 'SAMPLE'})), 1);

subtable_33 = size(unique(dataset_1b_not_full_time(dataset_1b_not_full_time.AGE > 35 & ...
    dataset_1b_not_full_time.EDUCD > 64 & dataset_1b_not_full_time.AGE <= 54, {'CBSERIAL', 'SAMPLE'})), 1);

subtable_41 = size(unique(dataset_1b_not_full_time(dataset_1b_not_full_time.AGE > 55 & ...
    dataset_1b_not_full_time.EDUCD < 20, {'CBSERIAL', 'SAMPLE'})), 1);

subtable_42 = size(unique(dataset_1b_not_full_time(dataset_1b_not_full_time.AGE > 55 & ...
    dataset_1b_not_full_time.EDUCD >= 20 & dataset_1b_not_full_time.EDUCD < 65, {'CBSERIAL', 'SAMPLE'})), 1);

subtable_43 = size(unique(dataset_1b_not_full_time(dataset_1b_not_full_time.AGE > 55 & ...
    dataset_1b_not_full_time.EDUCD > 64, {'CBSERIAL', 'SAMPLE'})), 1);

subtable = [subtable_11, subtable_12, subtable_13;
    subtable_21, subtable_22, subtable_23; 
    subtable_31, subtable_32, subtable_33;
    subtable_41, subtable_42, subtable_43];
