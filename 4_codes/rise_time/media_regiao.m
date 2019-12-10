function [ value ] = media_regiao ( signal, index, num_of_left_values, num_of_right_values )
%media_regiao Calcula o valor médio dos pontos de um determinado
%   sinal em torno de uma certa região.
%   A média será calculada em um determinado indice, incluindo
%   as amostras a esquerda e a direita do indice.

start_index = index - num_of_left_values;
end_index = index + num_of_right_values;

range = signal(start_index : end_index);

value = mean(range);

end

