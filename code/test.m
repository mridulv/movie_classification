final_a = [];
error_rating = [];
val = [];
counter = 0;
for k=1:size(movies_genre,1)
    error_rating = [];
    k
    for i=1:size(test_indices)
        if ( ratings(test_indices(i),k) ~= 0 )
            counter = 1;
            dot_pro = dot(movies_genre(k,:),cluster_rating(test_clusters(i),:));    
            error = dot_pro/size(find(movies_genre(k,:)),2) - ratings(test_indices(i),k);
            error_rating = [error_rating error*error];
        end
    end
    if (counter == 1)
        val = [val mean(error_rating)];
        counter = 0;
    end
end