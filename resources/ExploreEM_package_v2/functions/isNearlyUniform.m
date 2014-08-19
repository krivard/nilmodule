function [decision maxWt maxI]=isNearlyUniform(criterion, P_Cj_Xi, numClasses)
decision = 0;
P_Cj_Xi = normrow(P_Cj_Xi);
[minWt minI] = min(P_Cj_Xi);
if (minWt < 1E-6)
    minWt = 1E-6;
end
[maxWt maxI]  = max(P_Cj_Xi);
if (size(maxI,1) == 0 || size(maxI,2)==0)
    maxI = -1;
end

if (maxWt < 1E-6)
    maxWt =  2E-6;
end

if (criterion == 0 && maxWt/minWt <= 2)
    decision = 1;
elseif criterion == 1 
        uniformDist = 1/numClasses * ones(1, numClasses);
        kldiv = JSDiv(P_Cj_Xi, uniformDist);
        if ((kldiv < 1/numClasses)|| (sum(P_Cj_Xi) < 1))
            decision = 1;
        end
end