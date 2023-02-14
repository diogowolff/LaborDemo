dataset_4 = dataset(dataset.SEX == 1 & dataset.MARST < 3 & dataset.AGE >= 25 & ...
    dataset.AGE <= 55 & dataset.YEAR == 2015 & dataset.EMPSTAT == 1, :);

dataset_4.NLINC = dataset_4.HHINCOME - dataset_4.INCWAGE;
dataset_4.Wage = dataset_4.INCWAGE ./ (dataset_4.UHRSWORK .* dataset_4.WKSWORK2);
dataset_4.WorkTot = (dataset_4.UHRSWORK .* dataset_4.WKSWORK2);

dataset_4 = dataset_4(:, {'EDUC', 'Wage', 'NLINC', 'WorkTot', 'INCTOT'});

options = optimoptions(@fminunc,'Display','iter','Algorithm','quasi-newton');

GMM([0, 0, -3000], dataset_4)
test = fminunc(@(x) GMM(x, dataset_4), [0, 0, -3000], options);