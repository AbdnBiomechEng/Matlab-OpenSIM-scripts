% Script to loop through all files in a folder and apply operation

% Path to file folder
path_folder='C:/tmp'; 

% All files in this folder - change the .mat extension to the extension of
% your files
all_files=dir([path_folder '/*.mat']); 

% Loop through all files
for ifile=1:length(all_files)
    
    % Name of each file
    filename=[path_folder '/' all_files(ifile).name];

    % Apply operation to file, e.g. load(filename)

end
