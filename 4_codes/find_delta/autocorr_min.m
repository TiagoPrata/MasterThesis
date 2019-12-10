function [ ry, ry_quad, ty, ty_quad, tm ] = autocorr_min ( signal )
%autocorr_with_delta Esta funcao calcula a autocovariancia linear
%   e quadratica do sinal de trabalho (signal) e encontra o
%   menor minimo entre elas

ry = autocorr(signal, length(signal) - 1);
ry_quad = autocorr(signal.^2, length(signal) - 1);

%% Calcula os mínimos das autocovariâncias

ty = find(ry <= min(ry));
ty = ty(1);
ty_quad = find(ry_quad <= min(ry_quad));
ty_quad = ty_quad(1);

%% Encontra valor de trabalho tm

tm_y = min(ty, ty_quad);


%% Resultado

tm = tm_y;

end

