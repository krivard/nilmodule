function [XNorm l2Norm] = row_l2Norm( X )
% Returns rowwise L2 normalized version of X

    d = sqrt(sum((X .* X), 2));
    l2Norm = d;
    d=spfun(@(x)x.^-1,d);    
    D=spdiags(d,0,size(X,1),size(X,1));
    XNorm = D*X;
end

