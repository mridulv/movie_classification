close all;
clear all;
%clc;

numclusters = 20;
trainset_percentage = 80;


 matrix = dlmread('ml-100k\u.data');
 matrix =  matrix(:, 1:3);
ratings = zeros(943,1682);
for i=1:size(matrix,1)
    ratings(matrix(i,1), matrix(i,2)) = matrix(i,3);
end
 
 [train_data, test_data, train_indices] = splitdata(matrix, trainset_percentage);
 [norm_ratings,mu_bar, sigma_bar, mu_movies, sigma_movies] = data2rating(train_data, train_indices);
 ratings_train_norm = norm_ratings(train_indices,:);
 
ratings_train  = ratings(train_indices,:);
 

load('movies_genre.mat');
genre_size = zeros(1,19);
for i=1:19
    t = movies_genre(:,i);
    genre_size(i) = size(find(t),1);
end
 

user_profile_genre = zeros(size(train_indices,1), 19);
for i=1:size(train_indices,1)
    k=0;
    for j=1:1682
        if ratings_train(i,j)~=0
            user_profile_genre(i,:) = user_profile_genre(i,:) + movies_genre(j,:);
            k=k+1;
        end
    end
    user_profile_genre(i,:)= user_profile_genre(i,:)./k;
end

movies_genre_modified=movies_genre;
movies_genre_modified(find(movies_genre_modified==0))=-1;

user_profile_rating = zeros(size(train_indices,1), 19);
 k=zeros(size(train_indices,1),19);
for i=1:size(train_indices,1)
    for j=1:1682
        if ratings_train_norm(i,j)~=-5
            user_profile_rating(i,:) = user_profile_rating(i,:) + (ratings_train_norm(i,j)*movies_genre(j,:));
            k(i,:)=k(i,:)+movies_genre(j,:);
        end
    end
end
user_profile_rating = user_profile_rating./k;
ix = isnan(user_profile_rating);
user_profile_rating(find(ix)) = 0;



IDX = kmeans(user_profile_rating, numclusters);    

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

% states = 'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY'};
% states_index = [1:51]
% states_mapping = containers.Map(states, states_index)

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



save('method2_before_dt.mat');
decision_tree = ClassificationTree.fit(X,Y,'CategoricalPredictors',[2 3], 'PredictorNames', {'Age','Gender','Occupation'});
%view(decision_tree,'mode','graph') % graphic description


cluster_seen = zeros(numclusters, 19);
users_in_cluster = zeros(numclusters,1);
for i=1:size(train_indices,1)
    cluster = IDX(i);
    cluster_seen(cluster, :) = cluster_seen(cluster, :) + user_profile_genre(i,:);
    users_in_cluster(cluster,1) = users_in_cluster(cluster,1)+1;
end
for i=1:numclusters
cluster_seen(i,:) = cluster_seen(i,:)/users_in_cluster(i,1);
end

% Average rating of users in a cluster for each genre
cluster_rating = zeros(numclusters, 19);
users_in_cluster = zeros(numclusters,1);
for i=1:size(train_indices,1)
    cluster = IDX(i);
    cluster_rating(cluster, :) = cluster_rating(cluster, :) + user_profile_rating(i,:);
    users_in_cluster(cluster,1) = users_in_cluster(cluster,1)+1;
end

for i=1:numclusters
cluster_rating(i,:) = cluster_rating(i,:)/users_in_cluster(i,1);
end

test_indices = setdiff([1:943],train_indices)';
test_clusters = predict(decision_tree, user_data(test_indices,:));


threshold = [0.1];
 for i = 1 : size(test_indices,1)
        c = test_clusters(i);
        for j=1:size(ratings,2)
            a = (movies_genre(j,:).*cluster_seen(c,:));
            test_prob(i,j) = mean(a(find(a)));
            test_prediction(i, j) = sum(movies_genre(j,:).*cluster_rating(c,:))/sum(movies_genre(j,:));
        end
 end
 

 
 
a = ratings(test_indices,:);
index1 = find(a);
index2 = setdiff([1:size(test_indices,1)*size(ratings,2)],index1);
error1 = zeros(size(threshold));
error2 = zeros(size(threshold));
for l = 1: size(threshold,2)
    test_prediction1=zeros(size(test_indices,1), size(ratings,2));
    for i = 1 : size(test_indices,1)
        for j=1:size(ratings,2)
            if test_prob(i,j)>threshold(l)
                test_prediction1(i, j) = test_prediction(i, j);
            end
        end
    end
 count1 =0;
 count2=0;
 for i=1:size(test_prediction,1)
     for j=1:size(test_prediction,2)
         if ratings(test_indices(i),j)~=0
             count2 = count2+1;
             if test_prediction1(i,j)~=0
             error1(l) = error1(l) + abs(ratings(test_indices(i),j) - test_prediction1(i,j))^2;
              count1 = count1+1;
             elseif test_prediction1(i,j)==0
                 %count2 = count2+1;
                 error2(l)=error2(l)+1;
             end
%          else 
%              count2=count2+1;
%              if test_prediction1(i,j)~=0
%                  error2(l)=error2(l)+1;
%              end
         end
     end
 end
 error1(l)=error1(l)/count1;
 error2(l) = error2(l)/count2;
    %error1(l) = sum(abs(a(index1) - test_prediction1(index1)))/size(index1,1);
    %error2(l) = size(find(test_prediction1(index2)),2)/size(index2,2);%mean(mean(abs(ratings(index2) - test_prediction1(index2))));
end

fprintf('Error in Predicting whether a user sees a movie: %f%%\n',error2*100);
fprintf('NRMSE Error in Predicting the ratings: %f\n', sqrt(error1)/4);
