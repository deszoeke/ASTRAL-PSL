function psi = psi_ft(zet)
% dimensionless stability function for the temperature structure function,
% which we use for both humidity and temperature since they end up being
% similar. We have measured both and aren't convinced the q function is any
% different

psi = 5.5./(1 - 7.0*zet).^0.667;
uns = find(zet>0);
if ~isempty(uns)
    psi(uns) = 5.5*(1 + 2.5*zet(uns).^0.667);
end
