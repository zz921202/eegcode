This folder contains code built by Jimmy(zz22@rice.edu) to streamline to conversion and processing of eegsignal from multiple sources.

1. Before running codes from the first time, put data file “processed_data” in the same directory as README if it is not there. Do not change the name as it is used in some codes. 

2. For each session, always run “InitEEGLab.init()” first. It will load all the libraries and capture relevant variables for subsequent use.

3. SVMLight requires installation of “awk” to write files for svmlight software.

4. Description of folders: 
    learning: contains codes for supervised and unsupervised learning as well as supporting infrastructure, like evaluation and logging.
    load: deals with loading and prepossessing data from raw data sources
    sample_codes: CONTAINS sample code to use all functionalities. It is a good starting point for exploration
    old: historical code, will be removed in the future
    processed_data: stores all data in eeglab compatible format
    window_feature: feature extraction classes.

    Did not document the code well, so feel free to contact zz22@rice.edu if there is any ambiguities.


5. It is built on Mac and hence may not be compatible with other platforms.




