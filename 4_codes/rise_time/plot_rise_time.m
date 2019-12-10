%% Description
%  Este script plota os tempos de subida dos sensores 1 e 2.

%% plotando gráfico - Sensor 1
y1_tau_lineX = y1_tau * ones(1, 2);
y1_tau_lineY = y1_tau_value * ones(1, 2);
y1_final_lineY = valor_final_y1 * ones(1, 2);

figure(1);
plot(ensaios.('time'), y1_fromZero, 'k-', ...
     y1_tau_lineX, [0 y1_tau_value], 'r--', ...
     [0 y1_tau], y1_tau_lineY, 'r--', ...
     [0 length(y1_fromZero)*Ts], y1_final_lineY, 'b--')
 
legend({'Sendor de Temp 1', ...
        strcat('t=',int2str(y1_tau),'s')}, ...
        'FontSize',14, ...
        'Location', 'best');
    
title('Tempo de subida - Sensor de Temperatura 1', 'FontSize', 14);
xlabel('Tempo (s)', 'FontSize', 14) 
ylabel({'Temperatura (ºC)';'[Temp. inicial subtraida]'}, 'FontSize', 14);

%% plotando gráfico - Sensor 2
y2_tau_lineX = y2_tau * ones(1, 2);
y2_tau_lineY = y2_tau_value * ones(1, 2);
y2_final_lineY = valor_final_y2 * ones(1, 2);

figure(2);
plot(ensaios.('time'), y2_fromZero, 'k-', ...
     y2_tau_lineX, [0 y2_tau_value], 'r--', ...
     [0 y2_tau], y2_tau_lineY, 'r--', ...
     [0 length(y2_fromZero)*Ts], y2_final_lineY, 'b--')
 
legend({'Sendor de Temp 2', ...
        strcat('t=',int2str(y2_tau),'s')}, ...
        'FontSize',14, ...
        'Location', 'best');
    
title('Tempo de subida - Sensor de Temperatura 2', 'FontSize', 14);
xlabel('Tempo (s)', 'FontSize', 14) 
ylabel({'Temperatura (ºC)';'[Temp. inicial subtraida]'}, 'FontSize', 14);