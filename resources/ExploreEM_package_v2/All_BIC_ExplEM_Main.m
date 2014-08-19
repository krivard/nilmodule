% Bhavana Dalvi <bbd@cs.cmu.edu>
% School of Computer Science, Carnegie Mellon University
% Created: 2nd October 2013

addpath('./functions/');

% Maximum number of EM iterations (algorithm might terminate earlier
% if log likelihood/cluster assignments converge)
maxNumIter = 50;

% represnetation : 0 - K-Means
repr = 0;
representation = 'KM';

% hard = 1 : Hard assignments of points to clusters
%            Every datapoint belongs to only one of the clusters
% hard = 0 : Soft assignments of points to clusters
hard = 1;

% Criterion = 0 : MinMax criterion
%           = 1 : JS divergence
criterion = 0;


% experiment ID : used to create filename
exptID = '1';

% model selection criterion can be one of
% AIC / BIC / AICC criteria
modelSelection = 'AICC';

% You can set it to the current directory absolute path
% if the `.' doesnt work
directory = './';

% The data directory that contains X, Y, seeds etc
data = [directory './data/'];

% Load data
% Load X : numDocs * features
filename = [data 'data.X.txt'];
temp1 = load(filename);
X = sparse(temp1(:, 1), temp1(:,2), temp1(:,3));
numDocs = size(X,1);

% Load known labels
%filename = [data 'label_names.txt'];
%labels = textread(filename,'%s', 'delimiter', '\n');
filename = [data 'data.Y.txt'];
YT = load(filename);
Y = YT(:,2);
actualNumClasses = max(Y);
AllStats = [];

GlobalStats = [];
numClustersExplore = [];
numClustersSemisup = [];

filename = [data 'seeds.Y.txt'];
seedsTemp = [];
if exist(filename, 'file')
	seedsToDisk = load(filename);

	% Important: If there are k seed classes, but the class-ids in the seeds.Y.txt are not
	% 1 to k, then this code converts them to 1 to k.
	% Please not that output of this code is just a bunch of clusters.
	% You have to map them back to labels you want.
	% If seeds.Y.txt is sorted by class-id and class-ids are 1 to k,
	% then first k clusters in the output will same as class-ids 1 to k.
	% If that is not true, then the output cluster ids might not correspond to
	% seed cluster ids.
	maxClass = max(seedsToDisk(:,2));
	uniqClass = unique((seedsToDisk(:,2)));
	
	% Number of seed classes
        %length(uniqClass)
	numSeedClasses = length(uniqClass);
	
	revIndex = zeros(1, maxClass);
	for c = 1 : numSeedClasses
	    revIndex(uniqClass(c)) = c;
	end
	seedsTemp = [];
	for e = 1 : size(seedsToDisk,1)
    		c = revIndex(seedsToDisk(e, 2));
    		seedsTemp = [seedsTemp; seedsToDisk(e,1) c 1];
	end
	seeds = sparse(seedsTemp(:,1), seedsTemp(:,2), seedsTemp(:,3), numDocs, numSeedClasses);
else 
	numSeedClasses = 0;
	seedsToDisk = [];
	seeds = [];
end

% 1 : exploreEM : the algorithm will populate seed classes/clusters and
%                 also add new clsuters if needed.
% 0 : semisupEM : this algorithm will only populate the seed
%                 classes/clusters and won't add any new clusters.
for explore = 1:1
    S=sprintf('##################### PARAMS ############################ ');
    disp(S);
    [numSeedClasses maxNumIter repr hard explore criterion]
    
    if  criterion == 0
        heur = 'minmax';
    elseif criterion == 1
        heur = 'JS';
    end
    
    if strcmp(representation, 'KM') == 1
        [P_Cj_XiNorm stats centroids] = ABIC_ExplEM_KM(X, Y, seeds,numSeedClasses,  explore, criterion, maxNumIter, modelSelection, hard);
    else
        S=sprintf('ERROR : Unknown representation');
        disp(S);
    end
    
    if explore == 1
        algo = 'explore';
        numClustersExplore = [numClustersExplore; numSeedClasses maxNumIter repr hard explore criterion stats];
    else
        numClustersSemisup = [numClustersSemisup; numSeedClasses maxNumIter repr hard explore criterion stats];
        algo = 'semisup';
    end
    GlobalStats = [numSeedClasses maxNumIter repr hard explore criterion stats];
    AllStats = [AllStats; numSeedClasses maxNumIter repr hard explore criterion stats];
     
    outputFilePrefix = [data representation '_run' exptID '_' heur '_' modelSelection '_hard'  int2str(hard) '_' algo  '_s' int2str(numSeedClasses) '_iter' int2str(maxNumIter)];
    
    % Save cluster assignments for each data point
    f = full(P_Cj_XiNorm);
    filename = [outputFilePrefix '.assgn.txt'];
    dlmwrite(filename, f, 'precision', 7, 'delimiter', '\t');
    f = [];

    % Save centroids definitions
    filename = [outputFilePrefix '.centroids.txt']; 
    cf= full(centroids);
    dlmwrite(filename, cf, 'precision', 7, 'delimiter', '\t');
    cf = [];
    
    % Save seeds used by the algorithm
    filename = [outputFilePrefix '.seeds.txt'];
    dlmwrite(filename, seedsToDisk, 'precision', 7, 'delimiter', '\t');
    
    % Save other stats produced while running the algorithm
    % Format: numSeedClasses   maxNumIter   repr    hard   explore  criterion   iter numClasses timeTaken avgL2 newClassProbability
    filename = [outputFilePrefix '.clusters.txt'];
    dlmwrite(filename, GlobalStats, 'precision', 7, 'delimiter', '\t');
end
S=sprintf('numSeedClasses maxNumIter repr  hard   explore  criterion   iter numClasses timeTaken avgL2 newClassProbability');
disp(S);
GlobalStats
AllStats;

