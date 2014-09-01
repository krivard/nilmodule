% Bhavana Dalvi <bbd@cs.cmu.edu>
% School of Computer Science, Carnegie Mellon University
% Created: 2nd October 2013

function [P_Cj_XiNorm stats centroids probNewClass P_Cj_Xi]=ABIC_ExplEM_KM(X, Y, seeds, numSeedClasses, explore, criterion, maxNumIter, modelSelection, hard)
% X : data : |doc| * |features|
% Y : labels : |doc| * 1
% seeds : seed labels : |doc| * |numSeedClasses|
% numSeedClasses
% explore : 1 if exploreEM, 0 otherwise
% criterion : 0 if MinMax , 1 if JS
% maxNumIter : maximum number of EM iterations
% modelSelection : BIC/ AIC / AICC
% hard : 0  if soft EM, 1 if hard EM
size(Y)
%Y'
totalDataPoints = 0;
newClassDataPoints = 0;

convergenceThreshold = 1E-6;

numDocs = size(X,1);
numFeatures = size(X,2);
if numSeedClasses == 0
	labeledP =  zeros(numDocs,1);
else
	labeledP =  (sum(seeds,2) > 0);
end
OldAssgn = zeros(numDocs,1);
NewAssgn = [];
maxNumClassesAllowed = 100;

tic;
% Normalize data
XNorm = normrow(X);

% Compute initial centroids based on seeds
if (size(seeds,1) ==0 )
	centroids = [];
	centroidsNorm = [];
else
	[centroids centroidsNorm] = getClassParams(seeds, XNorm, 'kmeans');
end
numClasses = numSeedClasses;

numClusters = [];
oldLL = 0;
newLL = 0;

% for iter = 1 : t
for iter = 1 : maxNumIter
    S=sprintf('-------- KM Iteration : %d -------------', iter);
    disp(S);
        
    NewAssgn = zeros(numDocs,1);
    BaselineAssn = zeros(numDocs,1);
    
    BaselineLL = 0;
    ExploreLL = 0;
    BaselineNumClusters = numClasses;
    numClasses
    %iter
    % E step : Estimate P(cluster_j | X_i) based on cosine similarity
    S=sprintf('-------- KM Iteration : %d : E step started -------------', iter);
    disp(S);
    % P(C_j | X_i) = X_i dot C_j
    %numClasses
    if (numClasses == 0) 
	    P_Cj_Xi = [];
	    P_Cj_XiNorm = [];
    else 
	    P_Cj_Xi = XNorm * centroidsNorm';
	    % Normalize prob so that for a X_i they sum to 1
	    P_Cj_XiNorm = normrow(P_Cj_Xi);
    end
    
    %Keep this in case BIC criterion reverts to baseline model
    Baseline_P_Cj_Xi = P_Cj_Xi;
    BaselineNumClasses = numClasses;
    clusterSizes = zeros(numClasses, 1);
    
    % I step : Induce new class if needed
    S=sprintf('-------- KM Iteration : %d : I step started -------------', iter);
    disp(S);
    for i = 1:numDocs
        % Reassign seeds to original clusters
        if (labeledP(i) == 1)
            cID = find(seeds(i, :) > 0);
            maxWt = 1;
            [minWt minI] = min(P_Cj_XiNorm(i, :));
            BaselineLL = BaselineLL + log(1);
            BaselineAssn(i) = cID;
            P_Cj_Xi(i, :) = zeros(1, numClasses);
        else
            % Find out the entities which did not
            % belong to any of the existing
            % clusters, and put them in new clusters
            if (numClasses == 0)
	        decision =1;
                maxWt = 0;
                maxI = 0;
        	totalDataPoints = totalDataPoints+1;
	        newClassDataPoints = newClassDataPoints + decision;
            
            	Bdecision =1;
                BmaxWt = 1E-6;
                BmaxI = 0;
            	BaselineLL = BaselineLL + log(BmaxWt);
            	BaselineAssn(i) = BmaxI;
            else 
	        [decision maxWt maxI] = isNearlyUniform(criterion, P_Cj_XiNorm(i,:), numClasses);
        	totalDataPoints = totalDataPoints+1;
	        newClassDataPoints = newClassDataPoints + decision;
            
            	[Bdecision BmaxWt BmaxI] = isNearlyUniform(criterion, P_Cj_XiNorm(i,1:BaselineNumClasses), BaselineNumClasses);
            	BaselineLL = BaselineLL + log(BmaxWt);
            	BaselineAssn(i) = BmaxI;
            end
            if (explore && ((numClasses == 0) || (decision && numClasses < maxNumClassesAllowed)))
                % create a new cluster
                P_Cj_Xi = [P_Cj_Xi zeros(numDocs, 1)];
                P_Cj_XiNorm = [P_Cj_XiNorm zeros(numDocs, 1)];
                numClasses = numClasses + 1;
                %[i Y(i) numClasses]
                clusterSizes = [clusterSizes ; 0];
                
                % Assign datapoint i to this new cluster
                % Infitialize new centroid = datapoint i
                maxWt = 1;
                cID = numClasses;
                centroids(cID, :) = XNorm(i, :);
                % Normalize the clusters-centroids so that each feature is a TFIDF weight
                centroidsNorm = normcol(centroids);
                % Normalize the clusters-centroids so that each row is a unit vector
                centroidsNorm = normrow(centroidsNorm);
                
                % Recompute assignments of entities ind+1 to numDocs
                % to this new cluster
                if (i < numDocs)
                    P_Cj_Xi(i+1:numDocs, cID) = XNorm(i+1:numDocs, :) * centroidsNorm(cID, :)';
                    P_Cj_XiNorm(i+1:numDocs, :) = normrow(P_Cj_Xi(i+1:numDocs, :));
                end
            else
                cID = maxI;
            end
        end
        if (hard == 1)
            P_Cj_Xi(i, :) = zeros(1, numClasses);
        end

        P_Cj_Xi(i, cID) = maxWt;
        NewAssgn(i) = cID;
        ExploreLL = ExploreLL + log(maxWt);
        %[i maxWt minWt]
        clusterSizes(cID) = clusterSizes(cID) + 1;
    end
    P_Cj_XiNorm =  normrow(P_Cj_Xi);
    
    % M step : Recompute cluster centroids given the assignment
    %          Normalize the centroids
    S=sprintf('-------- KM Iteration : %d : M step started -------------', iter);
    disp(S);
    
    if explore
        selectExplore = false;
        % Temp Recompute centorids
        TcentroidsTemp = P_Cj_XiNorm' * XNorm;
        TnumClasses = size(TcentroidsTemp,1);
        
        % Keep only those clusters which have at least 1 point assigned to it
        Tcentroids = TcentroidsTemp(1:numSeedClasses, :);
        for c = numSeedClasses+1 : numClasses
            if (sum(P_Cj_XiNorm(:,c)) > 0  && clusterSizes(c) > 1)
                Tcentroids = [Tcentroids ; TcentroidsTemp(c, :)];
            end
        end
        %ExploreLL = sum(sum(P_Cj_Xi));
        %BaselineLL = sum(sum(Baseline_P_Cj_Xi));
        TnumClasses = size(Tcentroids, 1);
        if (TnumClasses > BaselineNumClasses)
            BaselineLL = 0;
            ExploreLL = 0;
            Baseline_P_Cj_XiNorm = normrow(Baseline_P_Cj_Xi);
            for doc = 1: numDocs
                if (BaselineAssn(doc) > 0)
                    %[doc BaselineAssn(doc) size(Baseline_P_Cj_XiNorm)]
                    p = 0;
                    if (Baseline_P_Cj_XiNorm(doc, BaselineAssn(doc)) < 1E-12)
                        p = 1E-12;
                    else
                        p = Baseline_P_Cj_XiNorm(doc, BaselineAssn(doc));
                    end
                    BaselineLL = BaselineLL + log(p);
                end
                if (NewAssgn(doc) > 0)
                    p = 0;
                    if (P_Cj_XiNorm(doc, NewAssgn(doc)) < 1E-12)
                        p = 1E-12;
                    else
                        p = P_Cj_XiNorm(doc, NewAssgn(doc));
                    end
                    ExploreLL = ExploreLL + log(p);
                end
            end
            [selectExplore BaselineScore ExploreScore] = isModelSelectionCriterionStatisifed(numDocs, numFeatures, BaselineLL, BaselineNumClusters, ExploreLL, TnumClasses, modelSelection)
            
            if selectExplore
                % exploratory model selected
                S=sprintf('++++++++++ %s criterion satisfied', modelSelection);
                disp(S);
                newLL = ExploreLL;
            else
                S=sprintf('---------- %s criterion NOT satisfied', modelSelection);
                disp(S);
                explore = 0;
                NewAssgn = BaselineAssn;
                P_Cj_XiNorm = normrow(Baseline_P_Cj_Xi);
                newLL = BaselineLL;
            end
        end
    end
    
    % Recompute centorids
    S=sprintf('-------- KM Iteration : %d : Recomputing Centroids -------------', iter);
    disp(S);

    centroidsTemp = P_Cj_XiNorm' * XNorm;
    numClasses = size(centroidsTemp,1);
    
    % Keep only those clusters which have at least 1 point assigned to it
    centroids = centroidsTemp(1:numSeedClasses, :);
    for c = numSeedClasses+1 : numClasses
        if (sum(P_Cj_XiNorm(:,c)) > 0  && clusterSizes(c) > 1)
            centroids = [centroids ; centroidsTemp(c, :)];
        end
    end
    
    numClasses = size(centroids, 1);
    
    % Normalize the clusters-centroids so that each feature is a TFIDF weight
    centroidsNorm = normcol(centroids);
    % Normalize the clusters-centroids so that each row is a unit vector
    centroidsNorm = normrow(centroidsNorm);
    numClusters = [numClusters ; size(centroids, 1)];
    
    % Check for convergence
    if (explore)
        if (iter > 1) && (numClusters(iter-1) == numClusters(iter))
            % If hard assignments, then cluster assignments converged means
            % EM has converged
            if (hard && (sum(OldAssgn ~= NewAssgn)==0))
                break;
            % If soft assignments, then log likelihood converged means
            % EM has converged    
            elseif (hard==0 && abs(newLL- oldLL)<=convergenceThreshold)
                break;
            end
        end
    elseif (iter > 1)
        if (hard && (sum(OldAssgn ~= NewAssgn)==0))
            break;
        elseif (hard==0 && abs(newLL- oldLL)<=convergenceThreshold)
            break;
        end
    end
    oldLL = newLL;
    [iter numClusters(iter) abs(newLL- oldLL) abs(newLL- oldLL)]
    OldAssgn = NewAssgn;
end

[iter numClusters(iter) abs(newLL- oldLL) abs(newLL- oldLL)]
timeTaken = toc;

% Compute avg. L2 distance to centroid
avgL2 = 0;
% This code computes average L2 distance of each point to the centroid of
% the cluster it got assigned to. This code might take large amount of time
% for large datasets (datasets with millions of features), hence commented. 
% You can uncomment it if your datasets are small.

% TempP_Cj_Xi = XNorm * centroidsNorm';
% TempP_Cj_XiNorm = normrow(TempP_Cj_Xi);
% for i = 1:numDocs
%     [prob assn] = max(TempP_Cj_XiNorm(i, :));
%     centroidTemp = centroids;
%     centroidTemp(assn, :) = centroidTemp(assn, :) - prob*XNorm(i,:);
%     centroidsTempNorm = normcol(centroidTemp);
%     centroidsTempNorm = normrow(centroidsTempNorm);
%     avgL2 = avgL2 + norm(XNorm(i, :) - centroidsTempNorm(assn, :));
% end
avgL2 = avgL2 / numDocs;

% Computes the probability of creating new class during this run of KMeans 
probNewClass = newClassDataPoints/totalDataPoints;

stats = [iter numClasses timeTaken avgL2 newClassDataPoints/totalDataPoints];
