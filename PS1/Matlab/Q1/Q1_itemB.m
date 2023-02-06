%% Data processing as done in Mincer (1962)

dataset = dataset(dataset.RACE == 1 & dataset.MARST == 1, :);

heads_working_index = dataset(dataset.RELATE == 1 & dataset.INCWAGE > 0, 'CBSERIAL');

dataset = dataset(ismember(dataset(:,'CBSERIAL'), heads_working_index), :);