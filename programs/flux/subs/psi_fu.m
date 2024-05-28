function psi = psi_fu(zet)
% dimensionless stability function for the velocity structure function

psi = 3.9*(1./(1-20*zet).^0.333 - zet - 1./(7-zet)).^0.667;
uns = find(zet>0);
if ~isempty(uns)
%    psi(uns) = 0.90*3.9*(1 + 2.5*zet(uns).^0.667);
    psi(uns) = 0.9*3.8*(1 + 5*zet(uns)).^0.667;
end
