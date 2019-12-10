function [ delta ] = find_delta( signal )
%find_delta Funcao para encontrar o Delta que satisfaz 5 <= tm <= 25

%% Encontra tm para o sinal original

[ ry, ry_quad, ty, ty_quad, tm_orig ] = autocorr_min(signal);

%% Encontrar Delta para que 5 <= tm <= 25

if tm_orig > 25
    for i = 1:length(signal)
        [ ry, ry_quad, ty, ty_quad, tm ] = autocorr_min(signal(1:i:end));
        if (tm >= 5) && (tm <= 25)
            break
        end
    end
end

%% Resultado
delta = i;

end

