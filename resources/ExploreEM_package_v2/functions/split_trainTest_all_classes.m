% Bhavana Dalvi <bbd@cs.cmu.edu>
% School of Computer Science, Carnegie Mellon University
% Created: 2nd October 2013

function [XTrain YTrain namesTrain indTrain  XTest YTest namesTest indTest] = split_trainTest_all_classes( X, Y, trainPercent, names )
    maxLabel = max(Y);
    
%     XInd = find(YS~=maxLabel);
%     X = XS(XInd,:);
%     Y = YS(XInd);

    XTrain = [];
    YTrain = [];
    XTest  = [];
    YTest  = [];
    indTrain = [];
    indTest = [];
    uniqLabels = unique(Y);
    numLabels = size(unique(Y));
    
    for i = 1:numLabels
        XInd = find(Y==uniqLabels(i));
        Xtemp = X(XInd,:);
        Ytemp = Y(XInd);
    
        numR = length(XInd);
        numTrain = ceil(numR*trainPercent);
        rng('shuffle');
        r = randperm(numR);
        
        XTrain = [XTrain ; Xtemp(r(1:numTrain),:)];
        YTrain = [YTrain ; Ytemp(r(1:numTrain),:)];
        indTrain = [indTrain  r(1:numTrain)];
        XTest =  [XTest  ; Xtemp(r(numTrain+1:numR),:)];
        YTest =  [YTest  ; Ytemp(r(numTrain+1:numR),:)];
        indTest = [indTest r(numTrain+1:numR)];
    end
    
    if (size(names,1) > 0)
        namesTrain = names(indTrain);
        namesTest = names(indTest);
    else 
        namesTrain = [];
        namesTest = [];
    end
end

