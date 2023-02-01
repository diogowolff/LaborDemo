%% More deleting of datapoints

dataset = dataset(dataset.AGE >= 25 & dataset.AGE <= 55 & dataset.SEX == 2 & ...
    dataset.MARST < 3 & dataset.HHINCOME ~= 9999999, :);