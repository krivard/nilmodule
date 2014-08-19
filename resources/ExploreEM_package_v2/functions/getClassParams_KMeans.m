function [centroids centroidsNorm ] = getClassParams_KMeans( labels, X )

centroids = labels' * X ;

% Normalize the clusters-centroids so that each feature is a TFIDF weight
centroidsNorm = normcol(centroids);

% Normalize the clusters-centroids so that each row is a unit vector
centroidsNorm = normrow(centroidsNorm);

end

