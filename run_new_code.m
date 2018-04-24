% run new_code

close all
clear all
clc 

path = pwd;
benjamin_files = dir('benjamin/offline');
benjamin_files([benjamin_files.isdir]) = [];
emily_files = dir('emily/offline');
emily_files([emily_files.isdir]) = [];
juraj_files = dir('juraj/offline');
juraj_files([juraj_files.isdir]) = [];
filenames = extractfield(benjamin_files,'name');
filenames(end+1:end+size(emily_files,1)) =...
    extractfield(emily_files,'name');
filenames(end+1:end+size(juraj_files,1)) =...
    extractfield(juraj_files,'name');
for i=1:length(filenames)
    filename = filenames{i};
    if i < 4
        disp('Running Benjamin Files')
        filename = strcat(path,'/benjamin/offline/',filename);
    elseif i >=4 && i < 7
        disp('Running Emily Files')
        filename = strcat(path,'/emily/offline/',filename);
    else
        disp('Running Juraj Files')
        filename = strcat(path,'/juraj/offline/',filename);
    end
    new_code(filename);
end


