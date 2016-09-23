function fname=sparse_write(M, fname)
if nargin<2 
    [a,fname]=unix(['date +/tmp/_svm_%F_-%H:%M_%S%N']);
    fname=fname(1:end-1); % get rid of newline character
end

dlmwrite([fname '.svm1'],M,'delimiter',' ');
unix(['awk -F" " ''{printf $1" "; for (i=2;i<=NF;i++) {printf i-1":"$i " "}; print ""}'' ' fname '.svm1 > ' fname '.svm2']);
end