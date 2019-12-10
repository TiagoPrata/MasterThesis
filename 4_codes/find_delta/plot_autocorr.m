
[ ry1, ry1_quad, ty1, ty1_quad, tm1_orig ] = autocorr_min(ensaios.('y1_Media'));
[ ry2, ry2_quad, ty2, ty2_quad, tm2_orig ] = autocorr_min(ensaios.('y2_Media'));

figure();
subplot(2,2,1)
area(ry1);
title('Autocovariância linear - Sensor 1', 'FontSize', 14);
xlabel('Atraso (\tau)', 'FontSize', 14);
ylabel('r_{y^{*}}', 'FontSize', 14);
subplot(2,2,2)
area(ry1_quad);
title('Autocovariância não-linear - Sensor 1', 'FontSize', 14);
xlabel('Atraso (\tau)', 'FontSize', 14);
ylabel('r_{y^{*2''}}', 'FontSize', 14);
subplot(2,2,3)
area(ry2);
title('Autocovariância linear - Sensor 2', 'FontSize', 14);
xlabel('Atraso (\tau)', 'FontSize', 14);
ylabel('r_{y^{*}}', 'FontSize', 14);
subplot(2,2,4)
area(ry2_quad)
title('Autocovariância não-linear - Sensor 2', 'FontSize', 14);
xlabel('Atraso (\tau)', 'FontSize', 14);
ylabel('r_{y^{*2''}}', 'FontSize', 14);