function [ q_h_Xi q_h_XiNorm] = getNormProbMax( log_Fh_Xi )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    numCols = size(log_Fh_Xi, 2);
    numRows = size(log_Fh_Xi, 1);   
    if (numRows == 0 || numCols == 0)
        q_h_Xi = log_Fh_Xi;
        q_h_XiNorm = log_Fh_Xi;
        return;
    end
    minScore = 1E-6;
    maxScore = 1;
    q_h_Xi = log_Fh_Xi;
    for i = 1 : numRows
        maxLog = max(q_h_Xi(i, :));
        [size(log_Fh_Xi, 2) size(q_h_Xi(i, :), 2) numCols];
        q_h_Xi(i, :) = q_h_Xi(i, :)  - maxLog * ones(1, numCols);
        expProb = exp(q_h_Xi(i,:));
        expProb(isinf(expProb)) = 1E6;
        expProb(isnan(expProb)) = 1E-6;
        q_h_Xi(i, :) = expProb;   
        q_h_XiNorm(i, :) = normrow(expProb);
        q_h_XiNorm(i, isnan(q_h_XiNorm(i, :))) = minScore;  
        q_h_XiNorm(i, find(q_h_XiNorm(i, :) < minScore)) = minScore;  
        q_h_XiNorm(i, isinf(q_h_XiNorm(i, :))) = maxScore;
        q_h_XiNorm(i, find(q_h_XiNorm(i, :) > maxScore)) = maxScore;
    end
    q_h_XiNorm = normrow(q_h_XiNorm);
    
%     q_h_Xi =  log_Fh_Xi;
%     minScore = 1;
%     maxScore = 1E5;
%     numCols = size(log_Fh_Xi, 2);
%     numRows = size(log_Fh_Xi, 1);
%     for i = 1 : numRows
%         minP = min(log_Fh_Xi(i, :));
%         if (minP <= 0)      
%            const = abs(minP) + minScore;
%            q_h_Xi(i, :) = q_h_Xi(i, :) + (const * ones(1, numCols));
%         end        
%         q_h_Xi(i, isnan(q_h_Xi(i, :))) = minScore;  
%         q_h_Xi(i, isinf(q_h_Xi(i, :))) = maxScore;
%     end
%     q_h_Xi = normrow(q_h_Xi);    
end

