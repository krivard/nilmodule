% Creates a matrix W from A where the each row is normalized by its sum. If
% A is sparse W is sparse.
%
% Author: Frank Lin (frank@cs.cmu.edu)

function W=normrowSum(A, rowSum)
rowSum=spfun(@(x)x.^-1,rowSum);
D=spdiags(rowSum,0,size(W,1),size(W,1));
W=D*A;

end