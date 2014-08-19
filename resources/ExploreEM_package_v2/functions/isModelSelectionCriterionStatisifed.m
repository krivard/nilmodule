% Bhavana Dalvi <bbd@cs.cmu.edu>
% School of Computer Science, Carnegie Mellon University
% Created: 2nd October 2013

function [selectExplore BaselineScore ExploreScore] = isModelSelectionCriterionStatisifed(numDocs, numFeatures, BaselineLL, BaselineNumClusters, ExploreLL, ExploreNumClusters, modelSelection);
selectExplore = false;

if (strcmp(modelSelection, 'BIC')==1)
    % Apply BIC criterion to select model
    % BIC = -2 * loglikelihood(X | model) + m * log(n)
    % m = # free parameters
    % n = # data points
    BaselineBIC = BaselineLL - 1/2* BaselineNumClusters * numFeatures * log(numDocs);
    ExploreBIC = ExploreLL - 1/2 * ExploreNumClusters * numFeatures  * log(numDocs);
    
    if (ExploreBIC >= BaselineBIC)
        selectExplore = true;
    end
    BaselineScore = BaselineBIC;
    ExploreScore = ExploreBIC;
elseif (strcmp(modelSelection, 'AIC')==1)
    % Using AIC criterion
    bk = BaselineNumClusters * numFeatures;
    ek = ExploreNumClusters * numFeatures;
    BaselineAIC = BaselineLL - (bk);
    ExploreAIC = ExploreLL - (ek);
    
    if (ExploreAIC >= BaselineAIC)
        selectExplore = true;
    end
    BaselineScore = BaselineAIC;
    ExploreScore = ExploreAIC;
elseif (strcmp(modelSelection, 'AICC')==1)
    % Using AICC criterion
    bk = BaselineNumClusters * numFeatures;
    ek = ExploreNumClusters * numFeatures;
    BaselineAICC = BaselineLL - (bk) - (bk*(bk+1)/(numDocs-bk-1));
    ExploreAICC = ExploreLL - (ek) - (ek*(ek+1)/(numDocs-ek-1));
    
    if (ExploreAICC >= BaselineAICC)
        selectExplore = true;
    end
    BaselineScore = BaselineAICC;
    ExploreScore = ExploreAICC;
 elseif (strcmp(modelSelection, 'CAIC')==1)
    % Using AICC criterion
    bk = BaselineNumClusters * numFeatures;
    ek = ExploreNumClusters * numFeatures;
    BaselineCAIC = BaselineLL - (1/2 * (bk) * (1 + log(numDocs)));
    ExploreCAIC = ExploreLL - (1/2 * (ek) * (1 + log(numDocs)));
    
    if (ExploreCAIC >= BaselineCAIC)
        selectExplore = true;
    end
    BaselineScore = BaselineCAIC;
    ExploreScore = ExploreCAIC;   
 elseif (strcmp(modelSelection, 'AIC3')==1)
    % Using AIC3 criterion
    bk = BaselineNumClusters * numFeatures;
    ek = ExploreNumClusters * numFeatures;
    BaselineAIC3 = BaselineLL - 3/2 * (bk);
    ExploreAIC3 = ExploreLL - 3/2 * (ek);
    
    if (ExploreAIC3 >= BaselineAIC3)
        selectExplore = true;
    end
    BaselineScore = BaselineAIC3;
    ExploreScore = ExploreAIC3; 
 elseif (strcmp(modelSelection, 'AICU')==1)
    % Using AICU criterion
    bk = BaselineNumClusters * numFeatures;
    ek = ExploreNumClusters * numFeatures;
    BaselineAICU = BaselineLL - (bk) - ((numDocs * log(numDocs)) /(numDocs-bk-1)) ;
    ExploreAICU = ExploreLL - (ek) - ((numDocs * log(numDocs)) /(numDocs-ek-1));
    
    if (ExploreAICU >= BaselineAICU)
        selectExplore = true;
    end
    BaselineScore = BaselineAICU;
    ExploreScore = ExploreAICU;     
elseif (strcmp(modelSelection, 'LLR')==1)
    % Using LLR criterion
    % DONT KNOW HOW TO IMPLEMENT
    % **************************
%     bk = BaselineNumClusters * numFeatures;
%     ek = ExploreNumClusters * numFeatures;
%     LLR = - 2 * BaselineLL + 2 * ExploreLL;
%     
%     if (LLR)
%         selectExplore = true;
%     end
%     BaselineScore = BaselineLL;
%     ExploreScore = ExploreLL;
end
end

