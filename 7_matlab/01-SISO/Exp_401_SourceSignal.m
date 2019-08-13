fs = 1; % Sampling frequency (samples per second) 
 dt = 1/fs; % seconds per sample 

% Constant1
const1_gain = 0;
const1_duration = 30
const1_time = 0:dt:const1_duration;
const1_signal = const1_gain * ones(1,const1_duration/dt + 1);
% plot(const1_time, const1_signal);

% Constant2
const2_gain = 50;
const2_duration = 400;
const2_time = 0:dt:const2_duration;
const2_signal = const2_gain * ones(1,const2_duration/dt + 1);
% plot(const2_time, const2_signal);
 
% Ramp
ramp_duration = 500;
ramp_time = 0:dt:ramp_duration;
ramp_gain = -10;
ramp_offset = const2_gain;
ramp_signal = ramp_offset + (ramp_gain * (ramp_time/ramp_duration));
% plot(ramp_time,ramp_signal);

% Constant3
const3_gain = const2_gain + ramp_gain;
const3_duration = 300;
const3_time = 0:dt:const3_duration;
const3_signal = const3_gain * ones(1,const3_duration/dt + 1);
% plot(const3_time, const3_signal);

% Sine wave
 sine_wavefreq = 0.0013; % Sine wave frequency (hertz) 
 %%For one cycle get time period
 sine_period = 1/sine_wavefreq ;
 % time step for one time period 
 sine_time = 0:dt:sine_period+dt ;
 sine_gain = 12.5;
 sine_signal = const3_gain + sine_gain * sin(2*pi*sine_wavefreq*sine_time) ;
%  plot(sine_time,sine_signal) ;

% Constant4
const4_gain = const3_gain;
const4_duration = 100;
const4_time = 0:dt:const4_duration;
const4_signal = const4_gain * ones(1,const4_duration/dt + 1);
% plot(const4_time, const4_signal);

time = 0:dt:const1_duration + const2_duration + ramp_duration + const3_duration + sine_period+dt + const4_duration + (5*(1/dt));
signal = [const1_signal const2_signal ramp_signal const3_signal sine_signal const4_signal];
output = [time; signal];
plot(time, signal);
save('Exp_401_SourceSignal.mat','output')