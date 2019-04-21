# Linguagem:        Python
# Autor:            Tiago Correa Prata
# Disponivel em:    
# § \url{https://github.com/TiagoPrata/MasterThesis/blob/master/4_codes/mpc_example.py} §

import numpy as np
import math
from scipy import signal
from scipy.optimize import minimize
import matplotlib.pyplot as plt

# ----------------------------------
# Process params:
gain = 3.5              #[deg C]/[V]
theta_const = 23        #[s]
theta_delay = 3         #[s]
model_params = {
    'gain': gain,
    'theta_const': theta_const,
    'theta_delay': theta_delay
}

Temp_env_k = 25         #[deg C]

# ----------------------------------
# Time settings:

Ts = 0.5                #Time-step [s]
t_pred_horizon = 8

N_pred = int(t_pred_horizon/Ts)
t_start = 0
t_stop = 300
N_sim = int((t_stop-t_start)/Ts)
t = np.linspace(t_start, t_stop-Ts, t_stop / Ts)

# ----------------------------------
# Storage allocations
Temp_sp_array = t*0

# ----------------------------------
# MPC costs:

C_e = 1
C_du = 20
mpc_costs = {
    'C_e': C_e,
    'C_du': C_du
}

#----------------------------------
# Defining sequence for temp_out setpoint:

Temp_sp_const = 30      #[C]   
Ampl_step = 2           #[C]
Slope = -0.04           #[C/s]
Ampl_sine = 1           #[C]
T_period = 50           #[s]

t_const_start = t_start
t_const_stop = 100
t_step_start = t_const_stop
t_step_stop = 150
t_ramp_start = t_step_stop
t_ramp_stop = 200
t_sine_start = t_ramp_stop
t_sine_stop = 250
t_const2_start = t_sine_stop
t_const2_stop = t_stop

for k in range(N_sim):
    if (t[k] >= t_const_start and t[k] < t_const_stop):
        Temp_sp_array[k] = Temp_sp_const

    if (t[k] >= t_step_start and t[k] < t_step_stop):
        Temp_sp_array[k] = Temp_sp_const + Ampl_step

    if (t[k] >= t_ramp_start and t[k] < t_ramp_stop):
        Temp_sp_array[k] = Temp_sp_const + Ampl_step + Slope * (t[k] - t_ramp_start)
    
    if (t[k] >= t_sine_start and t[k] < t_sine_stop):
        Temp_sp_array[k] = Temp_sp_const + Ampl_sine * math.sin(2*math.pi * (1/T_period) * (t[k] - t_sine_start))
    
    if (t[k] >= t_const2_start):
        Temp_sp_array[k] = Temp_sp_const

#----------------------------------
#Initialization:

u_init = 0
N_delay = math.floor(theta_delay/Ts) + 1
delay_array = np.zeros(N_delay) + u_init

#----------------------------------
#Initial guessed optimal control sequence:

Temp_heat_sim_k = 0         #[C]
Temp_out_sim_k = 28         #[C]
d_sim_k = -0.5

#----------------------------------
#Initial values for estimator:

Temp_heat_est_k = 0         #[C]
Temp_out_est_k = 25         #[C]
d_est_k = 0                 #[V]

#----------------------------------
#Initial guessed optimal control sequence:
u_guess = np.zeros(N_pred) + u_init
u_guess = np.transpose(u_guess)

#----------------------------------
#Initial value of previous optimal value:
u_opt_km1 = u_init

# ----------------------------------
# Defining arrays for plotting:

t_plot_array = np.zeros(N_sim)
Temp_out_sp_plot_array = np.zeros(N_sim)
Temp_out_sim_plot_array = np.zeros(N_sim)
u_plot_array = np.zeros(N_sim)
d_est_plot_array = np.zeros(N_sim)
d_sim_plot_array = np.zeros(N_sim)

# ----------------------------------
# Matrices defining linear constraints for use in fmincon:

# A = []
# B = []
# Aeq = []
# Beq = []

# ----------------------------------
# Lower and upper limits of optim variable for use in fmincon:

u_max = 5
u_min = 0
u_ub = np.zeros(N_pred) + u_max
u_lb = np.zeros(N_pred) + u_min

u_delayed_k = 2

# ------------------------
# Calculation of observer gain for estimation of input disturbance, d:

A_est = np.array([[-1/theta_const, gain/theta_const],[0, 0]])
C_est = np.array([[1, 0]])
n_est = len(A_est)
Tr_est = 5
T_est = Tr_est/n_est
estimpoly = np.array([T_est*T_est, math.sqrt(2)*T_est, 1])
eig_est = np.roots(estimpoly)
K_est1 = signal.place_poles(A_est.transpose(), C_est.transpose(), eig_est)
K_est = K_est1.gain_matrix.transpose()

# Configuring continuous plotting
plt.ion()

def objective(u, state_est, Temp_sp_to_mpc_array):
    gain = model_params['gain']
    theta_const = model_params['theta_const']
    theta_delay = model_params['theta_delay']

    C_e = mpc_costs['C_e']
    C_du = mpc_costs['C_du']

    Temp_heat_k = state_est['Temp_heat_est_k']
    d_k = state_est['d_est_k']

    N_delay = math.floor(theta_delay/Ts) + 1
    delay_array = np.zeros(N_delay) + u[0]

    ru_km1 = u_opt_km1
    u_km1 = u[0]
    J_km1 = 0

    for k in range(N_pred):
        u_k = u[k]
        Temp_sp_k = Temp_sp_to_mpc_array[k]

        # Time delay
        u_delayed_k = delay_array[N_delay-1]
        u_nondelayed_k = u_k
        delay_array = np.insert(delay_array, 0, u_nondelayed_k)
        delay_array = delay_array[:-1]

        # Solving diff eq
        dTemp_heat_dt_k = (1/theta_const) * (-Temp_heat_k + gain *(u_delayed_k + d_k))
        Temp_heat_kp1 = Temp_heat_k + Ts*dTemp_heat_dt_k
        Temp_out_k = Temp_heat_k + Temp_env_k

        # Updating objective function
        e_k = Temp_sp_k - Temp_out_k
        du_k = (u_k - u_km1)/Ts
        J_k = J_km1 + Ts*(C_e * e_k**2 + C_du * du_k**2)

        # Time shift
        Temp_heat_k = Temp_heat_kp1
        u_km1 = u_k
        J_km1 = J_k

    return J_k

def constraints(u):
    cineq = np.array([])
    ceq = np.array([])

    return (cineq, ceq)

# Creating matrix
Temp_out_est_plot_array = np.zeros(N_sim - N_pred)

for k in range(N_sim - N_pred):
    t_k = t[k]
    t_plot_array[k] = t_k

    # -----------------------
    # Observer for estimating input-disturbance d using Temp_out:
    # Note: The time-delayed u is used as control signal shere.
    e_est_k = Temp_out_sim_k - Temp_out_est_k

    dTemp_heat_est_dt_k = (1/theta_const) * (-Temp_heat_est_k + gain*(u_delayed_k + d_est_k)) + K_est[0] * e_est_k
    dd_est_dt_k = 0 + K_est[1] * e_est_k

    Temp_heat_est_kp1 = Temp_heat_est_k + Ts*dTemp_heat_est_dt_k
    d_est_kp1 = d_est_k + Ts*dd_est_dt_k

    Temp_out_est_k = Temp_heat_est_k + Temp_env_k

    # ------------------------
    # Storage for plotting
    Temp_out_est_plot_array[k] = Temp_out_est_k
    d_est_plot_array[k] = d_est_k

    # ------------------------
    # Setpoint array to optimizer
    Temp_sp_to_mpc_array = Temp_sp_array[k:k+N_pred]
    Temp_out_sp_plot_array[k] = Temp_sp_array[k]

    # -------------------------
    # Estimated state to optimizer
    state_est = {
        'Temp_heat_est_k': Temp_heat_est_k,
        'd_est_k': d_est_k
    }

    # -----------------------
    # Calculating optimal control sequence
    u_opt = minimize(objective, u_guess, args=(state_est, Temp_sp_to_mpc_array), method='SLSQP')

    u_guess = u_opt.x.reshape(1,N_pred)
    u_k = u_opt.x[0]
    u_plot_array[k] = u_k
    u_opt_km1 = u_opt.x[0]

    # ------------------------
    # Applying optimal control signal to simulated process
    d_sim_k = -0.5
    d_sim_plot_array[k] = d_sim_k

    u_delayed_k = delay_array[N_delay-1]
    u_nondelayed_k = u_k
    delay_array = np.insert(delay_array, 0, u_nondelayed_k)
    delay_array = delay_array[:-1]

    dTemp_heat_sim_dt_k = (1/theta_const) * (-Temp_heat_sim_k + gain *(u_delayed_k + d_sim_k))
    Temp_heat_sim_kp1 = Temp_heat_sim_k + Ts*dTemp_heat_sim_dt_k
    Temp_out_sim_k = Temp_heat_sim_k + Temp_env_k

    Temp_out_sim_plot_array[k] = Temp_out_sim_k

    # ---------------------------
    # Time shift for estimator and for simulator
    Temp_heat_est_k = Temp_heat_est_kp1
    d_est_k = d_est_kp1

    Temp_heat_sim_k = Temp_heat_sim_kp1

    # ----------------------------
    # Continuous plotting
    x_lim_array = t_start
    x_lim_array = np.append(x_lim_array, t_stop)

    if (k > 0 and k < N_sim):
        plt.pause(0.1)

        plt.subplot(3,1,1)
        lineSP, lineSim, lineEst = \
        plt.plot([t_plot_array[k-1], t_plot_array[k]], \
                [Temp_out_sp_plot_array[k-1], Temp_out_sp_plot_array[k]], \
                'r-', \
                [t_plot_array[k-1], t_plot_array[k]], \
                [Temp_out_sim_plot_array[k-1], Temp_out_sim_plot_array[k]], \
                'b-', \
                [t_plot_array[k-1], t_plot_array[k]], \
                [Temp_out_est_plot_array[k-1], Temp_out_est_plot_array[k]], \
                'm-')
        if (k == 1):
            lineSP.set_label('SP')
            lineSim.set_label('sim')
            lineEst.set_label('est')
            plt.legend()
            plt.xlim(x_lim_array)
            plt.ylim([28, 33])
            plt.xlabel('t [s]')
            plt.ylabel('[deg C]')
        
        plt.subplot(3,1,2)
        lineU, = \
        plt.plot([t_plot_array[k-1], t_plot_array[k]], \
                [u_plot_array[k-1], u_plot_array[k]], \
                'b-')
        if (k == 1):
            lineU.set_label('u')
            plt.legend()
            plt.xlim(x_lim_array)
            plt.ylim([0, 5])
            plt.xlabel('t [s]')
            plt.ylabel('[V]')

        plt.subplot(3,1,3)
        line_d_est, line_d_sim = \
        plt.plot([t_plot_array[k-1], t_plot_array[k]], \
                [d_est_plot_array[k-1], d_est_plot_array[k]], \
                'r-', \
                [t_plot_array[k-1], t_plot_array[k]], \
                [d_sim_plot_array[k-1], d_sim_plot_array[k]], \
                'b-')
        if (k == 1):
            line_d_est.set_label('d est')
            line_d_sim.set_label('d sim')
            plt.legend()
            plt.xlim(x_lim_array)
            # plt.ylim([0, 5])
            plt.xlabel('t [s]')

        plt.draw()

plt.show(block=True)