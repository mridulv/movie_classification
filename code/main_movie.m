close all;
clear all;
clc;
fid = fopen('ml-100k\u.item');
mydata = textscan(fid, '%s','delimiter','\n');
fclose(fid);
data=[];
year = [];
a = [];
b = [];
final_data = [];


for i=1:size(mydata{1},1)
    a = strsplit_new(mydata{1}{i},'|');
    data = [data;strsplit_new(mydata{1}{i},'|')];
    m = a(3);
    val = [];
    for k=6:24
        val = [val;a{1,k}];
    end
    if (strcmp(m{1,1},''))
        year = 1995;
        final_data = [final_data;year a(6:24)];
    else
        b = strsplit_new(m{1,1},'-');
        pl = b(3);
        final_data = [final_data;str2num(pl{1,1}) a(6:24)];
    end
end

final = [];

for i=1:size(mydata{1},1)
    final(i,1) = final_data{i,1};
    for k=2:20
        final(i,k) = final_data{i,k} - 48;
    end
end


