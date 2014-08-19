function [classParams classParamsNorm] = getClassParams(labels, X, featureSpace)
    classParams = [];
    classParamsNorm = [];
    if (strcmp(featureSpace,'kmeans') == 1)
        [classParams classParamsNorm] = getClassParams_KMeans(labels, X);
    end
end

