% ASTRAL 2024 SST

clf()
plot(b10.datetime, b10.tsnk-0.52)
hold on
plot(b10.datetime, b10.tsea_s-0.12)
plot(b10.datetime, b10.tsea_in_s)

xlim([datetime(2024,5,18), datetime(2024,6,6)])
ylim([29, 32.5])
set(gca,'fontsize', 16)
legend("snake-0.52", "intake", "TSG-0.12")
legend boxoff