clear

disp(char(strcat('Inicio:', {' '}, datestr(datetime))))

%% Configuracoes
Experiments_path = './Ensaios';

Ts_actual = 0.25;           % Tempo de amostragem atual
Ts_target = 21;             % Tempo de amostragem desejado

estab_time = 1500;          % Tempo para estabilizacao do sistema

%{
Relacao entre quant. de treinamento e validacao
(ex. 60% treinamento -> 40% validacao)
%}
train_valid_rate = 0.6;

%% Carrega dados
ensaios_full = combinar_experimentos(Experiments_path);

% Ajusta tempo de amostragem para Ts = 21
Ts_rate = Ts_target/Ts_actual;
ensaios = ensaios_full(1:Ts_rate:end,:);

%% Criando modelo
tclabsp = iddata([ensaios.('Sensor1'), ensaios.('Sensor2')], ...
                 [ensaios.('Aquecedor1'), ensaios.('Aquecedor2')], ...
                 Ts_rate);
tclabsp.InputName  = {'Aquecedor1';'Aquecedor2'};
tclabsp.InputUnit = {'%';'%'};
tclabsp.OutputName = {'Sensor1';'Sensor2'};
tclabsp.OutputUnit = {'ºC';'ºC'};
tclabsp.Tstart = 0;

%% Selecionando faixa de treinamento

% Quant de amostras, excluindo estabilizacao
data_length = length(find(ensaios.('Time') >= estab_time));

% Encontra primeiro indice apos estabilizacao
train_start = find(ensaios.('Time') >= estab_time, 1, 'first');     
train_finish = train_start + round(data_length * train_valid_rate);

train = tclabsp(train_start:train_finish,:,:);

%% Selecionando faixa de validacao
valid_start = train_finish;
valid_finish = height(ensaios);

valid = tclabsp(valid_start:valid_finish,:,:);

%% Plotando planta + treinamento + validacao
 plot(tclabsp,train,valid)

%% Cria modelos funcao de transferencia
%poles = [S1H1 S1H2; S2H1 S2H2]
%zeros = [S1H1 S1H2; S2H1 S2H2]
%ex: sys = tfest(train, [2 2; 2 2], [1 1; 1 1],'Ts',Ts_target);

disp(char(strcat('TF:', {' '}, datestr(datetime))))
models_tf = struct();
max_poles = 5;
max_zeros = 4;

i = 0;
for pS1H1 = 2:max_poles
 for pS1H2 = 2:max_poles
  for pS2H1 = 2:max_poles
   for pS2H2 = 2:max_poles
    for zS1H1 = 1:max_zeros
     if (zS1H1 >= pS1H1), break, end
     for zS1H2 = 1:max_zeros
      if (zS1H2 >= pS1H2), break, end
      for zS2H1 = 1:max_zeros
       if (zS2H1 >= pS2H1), break, end
       for zS2H2 = 1:max_zeros
        if (zS2H2 >= pS2H2), break, end
        i = i+1;
        models_tf(i).name = strcat('tf', int2str(pS1H1), ...
                                         int2str(pS1H2), ...
                                         int2str(pS2H1), ...
                                         int2str(pS2H2), ...
                                         int2str(zS1H1), ...
                                         int2str(zS1H2), ...
                                         int2str(zS2H1), ...
                                         int2str(zS2H2));
                                     
        models_tf(i).model = tfest(train, [pS1H1 pS1H2; ...
                                           pS2H1 pS2H2], ...
                                          [zS1H1 zS1H2; ...
                                           zS2H1 zS2H2], ...
                                          'Ts', Ts_target);
                                      
        [y,fit,x0] = compare(valid, models_tf(i).model);
        models_tf(i).param_num = pS1H1+pS1H2+pS2H1+pS2H2+ ...
                                 zS1H1+zS1H2+zS2H1+zS2H2;
                             
        models_tf(i).fit = fit;
        models_tf(i).score = prod(fit,1);
        models_tf(i).pS1H1 = pS1H1;
        models_tf(i).pS1H2 = pS1H2;
        models_tf(i).pS2H1 = pS2H1;
        models_tf(i).pS2H2 = pS2H2;
        models_tf(i).zS1H1 = zS1H1;
        models_tf(i).zS1H2 = zS1H2;
        models_tf(i).zS2H1 = zS2H1;
        models_tf(i).zS2H2 = zS2H2;
        models_tf(i).MSE = models_tf(i).model.Report.Fit.MSE;
        models_tf(i).FPE = models_tf(i).model.Report.Fit.FPE;
        models_tf(i).AIC = models_tf(i).model.Report.Fit.AIC;
        models_tf(i).AICc = models_tf(i).model.Report.Fit.AICc;
        models_tf(i).nAIC = models_tf(i).model.Report.Fit.nAIC;
        models_tf(i).BIC = models_tf(i).model.Report.Fit.BIC;
       end
      end
     end
    end
   end
  end
 end
end

%% Cria modelos de espaco de estados

% sys = ssest(train, 1:10, 'Ts',Ts_target);

disp(char(strcat('SS:', {' '}, datestr(datetime))))
models_ss = struct();
for i=1:10
    name_ss = strcat('ss', int2str(i));
    models_ss(i).model = ssest(train, i, 'Ts',Ts_target);
    [y,fit,x0] = compare(valid, models_ss(i).name);
    models_ss(i).fit = fit;
    models_ss(i).order = i;
    models_ss(i).score = prod(fit,1);
    models_ss(i).MSE = models_ss(i).model.Report.MSE;
    models_ss(i).FPE = models_ss(i).model.Report.FPE;
    models_ss(i).AIC = models_ss(i).model.Report.AIC;
    models_ss(i).AICc = models_ss(i).model.Report.AICc;
    models_ss(i).nAIC = models_ss(i).model.Report.nAIC;
    models_ss(i).BIC = models_ss(i).model.Report.BIC;
end


%% Cria modelos ARX e OE

% arx
%sys = arx(train, [2*ones(2,2) 2*ones(2,2) 1*ones(2,2)]);
% oe
%sys = oe(train, [2*ones(2,2), 2*ones(2,2), ones(2,2)]);

disp(char(strcat('ARX e OE:', {' '}, datestr(datetime))))
na_range = 1:4;
na_size = ones(2,2);
na = bsxfun(@times,na_size,reshape(na_range,1,1,numel(na_range)));

nb_range = 1:4;
nb_size = ones(2,2);
nb = bsxfun(@times,nb_size,reshape(nb_range,1,1,numel(nb_range)));

nk_range = 0:4;
nk_size = ones(2,2);
nk = bsxfun(@times,nk_size,reshape(nk_range,1,1,numel(nk_range)));

models_arx = struct();
models_oe = struct();
i=0;
for na_i=1:size(na_range,2)
    for nb_i=1:size(nb_range,2)
        for nk_i=1:size(nk_range,2)
            i = i+1;
            models_arx(i).name = strcat('na_',int2str(na_i), ...
                                        '_nb_',int2str(nb_i), ...
                                        '_nk_',int2str(nk_i));
                                    
            models_arx(i).model = arx(train, [na(:,:,na_i) ...
                                              nb(:,:,nb_i) ...
                                              nk(:,:,nk_i)]);
                                          
            models_arx(i).aic = aic(models_arx(i).model);
            [y,fit,x0] = compare(valid, models_arx(i).model);
            models_arx(i).fit = fit;
            if (fit(1) <= 0) || (fit(2) <= 0)
                models_arx(i).score = 0;
            else
                models_arx(i).score = prod(fit,1);
            end
            
            
            models_oe(i).name = strcat('nb_',int2str(na_i), ...
                                       '_nf_',int2str(nb_i), ...
                                       '_nk_',int2str(nk_i));
                                   
            models_oe(i).model = oe(train, [na(:,:,na_i) ...
                                            nb(:,:,nb_i) ...
                                            nk(:,:,nk_i)]);
                                        
            models_oe(i).aic = aic(models_oe(i).model);
            [y,fit,x0] = compare(valid, models_oe(i).model);
            models_oe(i).fit = fit;
            if (fit(1) <= 0) || (fit(2) <= 0)
                models_oe(i).score = 0;
            else
                models_oe(i).score = prod(fit,1);
            end
        end
    end
end


%% Cria modelos armax
%sys = armax(train, [2*ones(2,2), 2*ones(2,2), 2*ones(2,1), ones(2,2)]);

disp(char(strcat('ARMAX:', {' '}, datestr(datetime))))
na_range = 1:4;
na_size = ones(2,2);
na = bsxfun(@times,na_size,reshape(na_range,1,1,numel(na_range)));

nb_range = 1:4;
nb_size = ones(2,2);
nb = bsxfun(@times,nb_size,reshape(nb_range,1,1,numel(nb_range)));

nc_range = 1:4;
nc_size = ones(2,1);
nc = bsxfun(@times,nc_size,reshape(nc_range,1,1,numel(nc_range)));

nk_range = 0:4;
nk_size = ones(2,2);
nk = bsxfun(@times,nk_size,reshape(nk_range,1,1,numel(nk_range)));

models_armax = struct();
i=0;
for na_i=1:size(na_range,2)
    for nb_i=1:size(nb_range,2)
        for nc_i=1:size(nc_range,2)
            for nk_i=1:size(nk_range,2)
                i = i+1;
                models_armax(i).name = strcat('na_',int2str(na_i), ...
                                              '_nb_',int2str(nb_i), ...
                                              '_nc_',int2str(nc_i), ...
                                              '_nk_',int2str(nk_i));
                                          
                models_armax(i).model = armax(train, [na(:,:,na_i) ...
                                                      nb(:,:,nb_i) ...
                                                      nc(:,:,nc_i) ...
                                                      nk(:,:,nk_i)]);
                                                  
                models_armax(i).aic = aic(models_armax(i).model);
                [y,fit,x0] = compare(valid, models_armax(i).model);
                models_armax(i).fit = fit;
                if (fit(1) <= 0) || (fit(2) <= 0)
                    models_armax(i).score = 0;
                else
                    models_armax(i).score = prod(fit,1);
                end
            end
        end
    end
end

%% Cria modelos bj
%sys = bj(train, [2*ones(2,2), 2*ones(2,1), ...
%                 2*ones(2,1), 2*ones(2,2), ones(2,2)]);

disp(char(strcat('BJ:', {' '}, datestr(datetime))))
nb_range = 1:4;
nb_size = ones(2,2);
nb = bsxfun(@times,nb_size,reshape(nb_range,1,1,numel(nb_range)));

nc_range = 1:4;
nc_size = ones(2,1);
nc = bsxfun(@times,nc_size,reshape(nc_range,1,1,numel(nc_range)));

nd_range = 1:4;
nd_size = ones(2,1);
nd = bsxfun(@times,nd_size,reshape(nd_range,1,1,numel(nd_range)));

nf_range = 1:4;
nf_size = ones(2,2);
nf = bsxfun(@times,nf_size,reshape(nf_range,1,1,numel(nf_range)));

nk_range = 1:4;
nk_size = ones(2,2);
nk = bsxfun(@times,nk_size,reshape(nk_range,1,1,numel(nk_range)));

models_bj = struct();
i=0;
for nb_i=1:size(nb_range,2)
    for nc_i=1:size(nc_range,2)
        for nd_i=1:size(nd_range,2)
            for nf_i=1:size(nf_range,2)
                for nk_i=1:size(nk_range,2)
                    i = i+1;
                    models_bj(i).name = strcat('nb_',int2str(nb_i), ...
                                               '_nc_',int2str(nc_i), ...
                                               '_nd_',int2str(nd_i), ...
                                               '_nf_',int2str(nf_i), ...
                                               '_nk_',int2str(nk_i));
                                           
                    models_bj(i).model = bj(train, [nb(:,:,nb_i) ...
                                                    nc(:,:,nc_i) ...
                                                    nd(:,:,nd_i) ...
                                                    nf(:,:,nf_i) ...
                                                    nk(:,:,nk_i)]);
                                                
                    models_bj(i).aic = aic(models_bj(i).model);
                    [y,fit,x0] = compare(valid, models_bj(i).model);
                    models_bj(i).fit = fit;
                    if (fit(1) <= 0) || (fit(2) <= 0)
                        models_bj(i).score = 0;
                    else
                        models_bj(i).score = prod(fit,1);
                    end
                end
            end
        end
    end
end

%% Cria modelo não-linear

% na = [S1-TermsOutputS1 S1-TermsOutputS2; ...
%       S2-TermsOutputS1 S2-TermsOutputS2]
% nb = [S1-NumTermosH1 S1-NumTermosH2; ...
%       S2-NumTermosH1 S2-NumTermosH2]
% nk = [S1-DelayH1 S1-DelayH2; S2-DelayH1 S2-DelayH2]

% na = [2 0; 0 2];
% nb = [2 2; 2 2];
% nk = [1 1; 1 1];
% Orders = [na,nb,nk];
% sys = nlarx(train, Orders);

disp(char(strcat('NLARX:', {' '}, datestr(datetime))))
models_nlarx = struct();
i=0;
for na_1=1:2
 for na_4=1:2
  for nb_1=0:2
   for nb_2=0:2
    for nb_3=0:2
     for nb_4=0:2
      for nk_1=0:2
       for nk_2=0:2
        for nk_3=0:2
         for nk_4=0:2
          i = i+1;

          na = [na_1 0; 0 na_4];
          nb = [nb_1 nb_2; nb_3 nb_4];
          nk = [nk_1 nk_2; nk_3 nk_4];

          Orders = [na,nb,nk];
          models_nlarx(i).name = strcat('na',int2str(na_1), ...
                                        '00',int2str(na_4), ...
                                        '_nb',int2str(nb_1), ...
                                        int2str(nb_2), ...
                                        int2str(nb_3), ...
                                        int2str(nb_4), ...
                                        '_nk',int2str(nk_1), ...
                                        int2str(nk_2), ...
                                        int2str(nk_3), ...
                                        int2str(nk_4));
                                    
          models_nlarx(i).model = nlarx(train, Orders);
          models_nlarx(i).aic = aic(models_nlarx(i).model);
          [y,fit,x0] = compare(valid, models_nlarx(i).model);
          models_nlarx(i).fit = fit;
          if (fit(1) <= 0) || (fit(2) <= 0)
              models_nlarx(i).score = 0;
          else
              models_nlarx(i).score = prod(fit,1);
          end
         end
        end
       end
      end
     end
    end
   end
  end
 end
end

%% Finalizando
disp(char(strcat('Termino:', {' '}, datestr(datetime))))