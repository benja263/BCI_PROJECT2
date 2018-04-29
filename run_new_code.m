% run new_code

close all
clear all
clc 
exists = false;
if  exist('psd_data.mat','file')
    load('psd_data.mat');
    exists = true;
end
benjamin_files = dir('benjamin/offline');
benjamin_files([benjamin_files.isdir]) = [];
emily_files = dir('emily/offline');
emily_files([emily_files.isdir]) = [];
juraj_files = dir('juraj/offline');
juraj_files([juraj_files.isdir]) = [];
kriton_files = dir('kriton/offline');
kriton_files([kriton_files.isdir]) = [];
filenames = cell(4,2);
filenames{1,1} = extractfield(benjamin_files,'name');
filenames{2,1} = extractfield(emily_files,'name');
filenames{3,1} = extractfield(kriton_files,'name');
filenames{4,1} = extractfield(juraj_files,'name');
filenames{1,2} = './benjamin/offline/';
filenames{2,2} = './emily/offline/';
filenames{3,2} = './kriton/offline/';
filenames{4,2} = './juraj/offline/';
disp('Adding Offline Files')
for i=1:length(filenames)
    files = filenames{i};
    filepath = filenames{i,2};
    for j=1:length(files)   
        filename = files{j};
        if exists 
            [psd_file,added] = new_code(filename,filepath,psd_file);
        else
            [psd_file,added] =  new_code(filename,filepath);
        end
        if added
            disp('Added file')
            disp(filename)
        else
            disp('File already exists')
            disp(filename)
            
        end
    end
end

%% adding online files
disp('Adding Online Files')
benjamin_files = dir('benjamin/online');
benjamin_files([benjamin_files.isdir]) = [];
emily_files = dir('emily/online');
emily_files([emily_files.isdir]) = [];
juraj_files = dir('juraj/online');
juraj_files([juraj_files.isdir]) = [];
kriton_files = dir('kriton/online');
kriton_files([kriton_files.isdir]) = [];
filenames = cell(4,2);
filenames{1,1} = extractfield(benjamin_files,'name');
filenames{2,1} = extractfield(emily_files,'name');
filenames{3,1} = extractfield(kriton_files,'name');
filenames{4,1} = extractfield(juraj_files,'name');
filenames{1,2} = './benjamin/online/';
filenames{2,2} = './emily/online/';
filenames{3,2} = './kriton/online/';
filenames{4,2} = './juraj/online/';
for i=1:length(filenames)
    files = filenames{i};
    filepath = filenames{i,2};
    for j=1:length(files) 
        filename = files{j};  
        if exists 
            [psd_file,added] = new_code(filename,filepath,psd_file);
        else
            [psd_file,added] =  new_code(filename,filepath);
        end
        added
        if added
            disp('Added file')
            disp(filename)
        else
            disp('File already exists')
            disp(filename)
            
        end
    end
end
disp('Done')
%% annonymous data
disp('Loading annonymous data')
filepath = './';
annon_files = dir();
annon_files([annon_files.isdir]) = [];
annon_names = extractfield(annon_files,'name');
indexes = zeros(length(annon_names),1);
for i=1:length(annon_names)
    name = annon_names{i};
    if strcmp(name(end-2:end),'gdf')
        indexes(i) = i;
    end
end
indexes = indexes(indexes ~= 0);
filenames = annon_names(indexes);
for j=1:length(filenames) 
    filename = filenames{j};  
    if exists 
        [psd_file, added] = new_code(filename,filepath,psd_file);
    else
        [psd_file,~] =  new_code(filename,filepath);
    end
    if added
        disp('Added file')
        disp(filename)
    else
        disp('File already exists')
        disp(filename)

    end
end
disp('Done')