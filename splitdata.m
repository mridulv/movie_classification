function [train, test, train_users] = splitdata(data, train_percent)

train = [];
test = [];
train_users = randsample(943, train_percent*943/100);
for i=1:size(data,1)
    if (any(train_users==data(i,1)))
        train = [train; data(i,:)];
    else
        test = [test; data(i,:)];
    end
end

        