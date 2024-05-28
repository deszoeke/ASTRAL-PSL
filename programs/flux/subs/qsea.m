function y=qsea(x)
% computes saturation e at sea surface given x = SST
es=6.112.*exp(17.502.*x./(x+241.0))*.98*(1.0007+3.46e-6*1010);
y=es*622./(1010.0-.378*es);