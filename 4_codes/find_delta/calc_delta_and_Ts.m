%% Description
%  Este script calcula a o menor delta para decimar a amostragem original

delta_y1 = find_delta(ensaios.('y1_Media'));
delta_y2 = find_delta(ensaios.('y2_Media'));

delta = min(delta_y1, delta_y2);
disp(char(strcat({'Delta = '}, num2str(delta))));

time_with_delta = ensaios.('time')(1:delta:end);

Ts = time_with_delta(2) - time_with_delta(1);
disp(char(strcat({'Tempo de amostragem = '}, num2str(Ts), 's')));

disp(' ');
disp('É possível utilizar o ensaio já realizado, aplicando delta para');
disp('evitar a superamostragem existente. Ex. sinal(1:delta:end)');
disp('Ou pode-se realizar um novo ensaio, utilizando Ts como intervalo');
disp('de amostragem.');