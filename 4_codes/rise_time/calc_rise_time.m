%% Description
%  Este script faz uma média de todos os resultados coletados
%  e através dela obtem o tempo de subida da resposta em malha
%  aberta dos Sensores 1 e 2.

%% Carregar média dos ensaios
data_folder_name = strcat(pwd, '\Ensaios');
ensaios = combinar_experimentos(data_folder_name);

%% calcula periodo de amostragem utilizado
Ts = ensaios.('time')(2) - ensaios.('time')(1);

%% encontrando valores iniciais das respostas dos Sensores
valor_inicial_y1 = media_regiao(ensaios.('y1_Media'), 1, 0, 5);
valor_inicial_y2 = media_regiao(ensaios.('y2_Media'), 1, 0, 5);

%% ajustando condicoes iniciais para zero
y1_fromZero = ensaios.('y1_Media') - valor_inicial_y1;
y2_fromZero = ensaios.('y2_Media') - valor_inicial_y2;

%% encontrando valores finais das respostas dos Sensores
valor_final_y1 = media_regiao(y1_fromZero, length(y1_fromZero), 5, 0);
valor_final_y2 = media_regiao(y2_fromZero, length(y2_fromZero), 5, 0);

%% encontrando valor correspondente a 63,21% do valor final das respostas
y1_tau_value = 0.6321*valor_final_y1;
y1_tau_index = find(y1_fromZero >= y1_tau_value);
y1_tau_index = y1_tau_index(1);
y1_tau = y1_tau_index * Ts;
disp(char(strcat({'Tempo de subida do sensor 1 = '}, num2str(y1_tau), 's')));

y2_tau_value = 0.6321*valor_final_y2;
y2_tau_index = find(y2_fromZero >= y2_tau_value);
y2_tau_index = y2_tau_index(1);
y2_tau = y2_tau_index * Ts;
disp(char(strcat({'Tempo de subida do sensor 2 = '}, num2str(y2_tau), 's')));