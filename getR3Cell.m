function [R3, J3] = getR3Cell(densityMatrix, transitionDipoleMatrix, ...
    t1TimeProp, t3TimeProp, t2TimeProp, lineshape1D, lineshape2D)

rho0 = cell(1, length(t1TimeProp.Norm)); 
rho0(:) = {densityMatrix*transitionDipoleMatrix};

transitionDipoleCell1 = cell(1, length(t1TimeProp.Norm));
transitionDipoleCell1(:) = {transitionDipoleMatrix};


rho1 = cellfun(@mtimes, rho0, t1TimeProp.Conj, 'UniformOutput', false);
rho1 = cellfun(@mtimes, t1TimeProp.Norm, rho1, 'UniformOutput', false);
rho1 = cellfun(@mtimes, transitionDipoleCell1, rho1, 'UniformOutput', false);

J3 = lineshape1D.*cellfun(@trace, rho1);

dim = size(densityMatrix);
a = ones(dim(1)/3, dim(2)/3);
block = blkdiag(a,a,a);

blockCell = cell(1, length(t1TimeProp.Norm));
blockCell(:) = {block};

t2TimePropCell = cell(1,length(t1TimeProp.Norm));
t2TimePropCellConj = cell(1,length(t1TimeProp.Norm));

t2TimePropCell(:) = {t2TimeProp.Norm};
t2TimePropCellConj(:) = {t2TimeProp.Conj};

rho2 = cellfun(@times, blockCell, rho1, 'UniformOutput', false);
rho2 = cellfun(@mtimes, t2TimePropCell, rho2, 'UniformOutput', false);
rho2 = cellfun(@mtimes, rho2, t2TimePropCellConj, 'UniformOutput', false);
rho2 = cellfun(@times, blockCell, rho2, 'UniformOutput', false);
rho2 = cellfun(@mtimes, transitionDipoleCell1, rho2, 'UniformOutput', false);
rho3 = cell(length(t3TimeProp.Norm), length(t1TimeProp.Norm));

t3TimePropCell = cell(length(t3TimeProp.Norm), length(t1TimeProp.Norm));
t3TimePropCellConj = cell(length(t3TimeProp.Norm), length(t1TimeProp.Norm));

for ii = 1:length(t1TimeProp.Norm)
    t3TimePropCell(:, ii) = t3TimeProp.Norm(:);
    t3TimePropCellConj(:, ii) = t3TimeProp.Conj(:);
end

transitionDipoleCell2 = cell(length(t3TimeProp.Norm), length(t1TimeProp.Norm));

for ii = 1:length(t3TimeProp.Norm)
    rho3(ii, :) = rho2(:);
    transitionDipoleCell2(ii, :) = transitionDipoleCell1(:);
end

rho3 = cellfun(@mtimes, rho3, t3TimePropCellConj, 'UniformOutput', false);
rho3 = cellfun(@mtimes, t3TimePropCell, rho3, 'UniformOutput', false);
rho3 = cellfun(@mtimes, transitionDipoleCell2, rho3, 'UniformOutput', false);

R3 = lineshape2D.*cellfun(@trace, rho3);