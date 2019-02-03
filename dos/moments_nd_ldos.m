% Local density of states using nested dissection method.
%
% Input:
%   A: Graph matrix.
%   N: Number of moments to compute.
%   perm: Nested dissection ordering.
%   tree: Nested dissection partition tree.
%   
% Output:
%   c: Local density of states up to N-th moment.

function c = moments_nd_ldos(A, N, perm, tree)
if nargin < 4
    [perm, tree] = ndmetis(A);
end
Ap = A(perm, perm);
assert(CheckValidTree(tree, Ap),'The nested dissection tree is not valid.');

n = length(A);
c = zeros(N, n);
Tk = MatrixPtr(speye(n));
Tj = MatrixPtr(Ap);
Mix(Tj, tree);
c(1, :) = 1;
c(2, :) = diag(Tj)';
for i = 3:N
    Ti = MatrixPtr(zeros(n));
    BuildRootColumns(tree, Ap, Ti, Tj, Tk);
    BuildLeafBlocks(tree, Ap, Ti, Tj, Tk);
    c(i, :) = diag(Ti)';
    Tk = Tj;
    Tj = Ti;
end
c(:, perm) = c;
end

function Mix(Tj, tree)
if ~isempty(tree.left)
    Mix(Tj, tree.left);
end
if ~isempty(tree.left)
    Mix(Tj, tree.left);
end
nRoot = length(tree.root);
nZ = max(min(nRoot, 1), ceil(nRoot));
Tj.data(:, tree.root(1:nZ)) = Tj.data(:,tree.root) * zeros(nRoot, nZ);
end