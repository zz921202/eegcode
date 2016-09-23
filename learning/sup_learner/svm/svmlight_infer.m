function margin = svmlight_infer(testing_data, model_name, data_dump_file)
% (very) simple wrapper for svmlight
% Writes matrices in sparse format to data file that can be used by svmlight.
% Columns are variables, rows are observations. 
% It is assumed that the first column of the matrix is the target. Targets are elements of {-1,1}.
%
% These steps are made: 
% 1. output matlab matrix to text file
% 2. format text file for svm (awk)
% 3. create classification model (svm_learn)
% 4. apply classification model (svm_classify)
%
% All files are written in the /tmp/ directory
%
% Example: 
% Y=svmlight(data(traininds,:),data(testinds,:),'-c 1 -w 3 -l 10 ');
% (if you set parameters for svmlight don't forget to include the learning options!)
%
% (c) Benjamin Auffarth, 2008
% licensed under CC-by-sa (creative commons attribution share-alike)

cur_dirname = fileparts(mfilename('fullpath'));
dump_dir = [cur_dirname, '/tmp/'];
model_file = [dump_dir, model_name];

if nargin< 3
    data_dump_file = sparse_write(testing_data);
else
    data_dump_file = [dump_dir, data_dump_file];
    data_dump_file = sparse_write(testing_data, data_dump_file);

end


[s,w]=unix([cur_dirname '/svm_classify -v 0 ' data_dump_file '.svm2 ' model_file '.model ' data_dump_file '.dat']);
% disp('debugging infer')
% [cur_dirname '/svm_classify -v 0 ' data_dump_file '.svm2 ' model_file '.model ' data_dump_file '.dat']
if s
   disp('error in executing smv-light!');
   w
    error('svm_perf_classify not found or returned error');
end

margin =dlmread([data_dump_file '.dat']);

end




