function [ratings, mu_bar, sigma_bar, mu_movies, sigma_movies] = data2rating(data, train_indices)
%DATA2RATING Summary of this function goes here
%   Detailed explanation goes here

lambda=25;
ratings = zeros(943,1682);
for i=1:size(data,1)
    ratings(data(i,1), data(i,2)) = data(i,3);
end
Means = zeros(size(ratings,1),1);
mu_i_hat = zeros(size(ratings,1),1);
sigma_i_hat = zeros(size(ratings,1),1);
Variance = zeros(size(ratings,1),1);
for j=1:size(train_indices,1)
    i = train_indices(j);
    Means(i) = mean(ratings(i,find(ratings(i,:))));
end
for j=1:size(train_indices,1)
    i = train_indices(j);
    Variance(i) = var(ratings(i,find(ratings(i,:))));
end
sigma = sqrt(Variance);
mu_bar = mean(Means(find(Means)));
sigma_bar = mean(sigma(find(sigma)));

for i=1:size(ratings,1)
    ratings_count = size(ratings,2)-sum(ratings(i,:)==0);
    if (ratings_count~=0)
        mu_i_hat(i) = (ratings_count*Means(i) + lambda*mu_bar)/(ratings_count + lambda);
        sigma_i_hat(i) = (ratings_count*sigma(i) + lambda*sigma_bar)/(ratings_count + lambda);
    end
end
 for j=1:size(train_indices,1)
    i = train_indices(j);
    for k=1:size(ratings,2)
        if (ratings(i,k)~=0)
            ratings(i,k) = (sigma_bar*(ratings(i,k)-mu_i_hat(i))/sigma_i_hat(i))+mu_bar;
        else 
            ratings(i,k)=-5;
        end
        
    end
 end
mu_movies = zeros(1682,1);
sigma_movies = zeros(1682,1);
for i=1:size(ratings,2)
    mu_movies(i)=mean(ratings(find(ratings(:,i)),i));
    sigma_movies(i)=var(ratings(find(ratings(:,i)),i));
end
 sigma_movies = sqrt(sigma_movies);
 
end


