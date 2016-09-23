function Y=svmlight(training,test,params)
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
if nargin<3
   params='-c 1 ';
end
trainfile=sparse_write(training);
[s,w]=unix(['./svm_learn ' params trainfile '.svm2 ' trainfile '.model']);
disp('original train')
['./svm_learn ' params trainfile '.svm2 ' trainfile '.model']

if s
   disp('error in executing smv-light!');w;
   error('svm_learn not found or returned error');
end

testfile=sparse_write(test);
[s,w]=unix(['./svm_classify -v 0 ' testfile '.svm2 ' trainfile '.model ' testfile '.dat']);
disp('original testing')
['./svm_classify -v 0 ' testfile '.svm2 ' trainfile '.model ' testfile '.dat']
if s
   disp('error in executing smv-light!');w;
    error('svm_perf_classify not found or returned error');
end
Y=dlmread([testfile '.dat']);
end

function fname=sparse_write(M)
[a,fname]=unix('date +/tmp/_svm_%F_-%H:%M_%S%N');
fname=fname(1:end-1); % get rid of newline character
dlmwrite([fname '.svm1'],M,'delimiter',' ');
unix(['awk -F" " ''{printf $1" "; for (i=2;i<=NF;i++) {printf i-1":"$i " "}; print ""}'' ' fname '.svm1 > ' fname '.svm2']);
end