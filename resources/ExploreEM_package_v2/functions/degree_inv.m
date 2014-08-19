% Creates a diagonal degree matrix D from W, where D(i,i) is the reciprocal
% of the row-sum of the i-th row of W. D will be a sparse matrix. D(i,i) is
% zero, not inf, if row i sum is zero.
%
% Author: Frank Lin (frank@cs.cmu.edu)

function D=degree_inv(W)

d=sum(W,2);
d=spfun(@(x)x.^-1,d);
D=spdiags(d,0,size(W,1),size(W,1));

end