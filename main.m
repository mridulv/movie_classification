close all;
clear all;
clc;

numclusters = 20;
trainset_percentage = 80;


 matrix = dlmread('ml-100k\u.data');
 matrix =  matrix(:, 1:3);
 [train_data, test_data, train_indices] = splitdata(matrix, trainset_percentage);
 [norm_ratings,mu_bar, sigma_bar, mu_movies, sigma_movies] = data2rating(train_data, train_indices);

 
 
%load('before_clustering.mat');
%train_indices = sort(train_indices);
ratings_norm_train = norm_ratings(train_indices,:);
IDX = kmeans(ratings_norm_train,numclusters);

%load('after_clustering.mat');

fid = fopen('ml-100k\user.csv');
mydata = textscan(fid, '%s');
fclose(fid);
data=[];
for i=1:size(mydata{1},1)
data = [data;strsplit_new(mydata{1}{i},',')];
end
for i=1:size(data,1)
data{i,1} = str2num(data{i,1});
data{i,2} = str2num(data{i,2});
end

user_data = zeros(size(data,1),3);
occupations = {'administrator','artist','doctor','educator','engineer','entertainment','executive','healthcare','homemaker', 'lawyer', 'librarian', 'marketing', 'none', 'other', 'programmer', 'retired', 'salesman', 'scientist', 'student', 'technician','writer'};
occupations_index = [1:21];
occupations_mapping = containers.Map(occupations,occupations_index);

gender = {'M', 'F'};
gender_index = [1:2];
gender_mapping = containers.Map(gender,gender_index);

for i=1:size(data,1)
   user_data(i,1) = data{i,2};
   user_data(i,2) = gender_mapping(data{i,3});
   user_data(i,3) = occupations_mapping(data{i,4});
end

X = user_data(train_indices,:);
Y = IDX;

save('before_dt.mat');

%%load('before_dt.mat');
decision_tree = ClassificationTree.fit(X,Y,'CategoricalPredictors',[2 3], 'PredictorNames', {'Age','Gender','Occupation'});
save('after_dt.mat');
%%load('after_dt.mat');

test_indices = setdiff([1:943],train_indices)';
test_clusters = predict(decision_tree, user_data(test_indices,:));

cluster_ratings = zeros(numclusters, 1682);
num_ratings = zeros(numclusters,1);
for i=1:size(train_indices,1)
cluster_ratings(IDX(i),:) = cluster_ratings(IDX(i),:)+ratings_norm_train(i,:);
num_ratings(IDX(i),1)=num_ratings(IDX(i),1)+1;
end

for i=1:numclusters
cluster_ratings(i,:) = cluster_ratings(i,:)/num_ratings(i,1);
end

