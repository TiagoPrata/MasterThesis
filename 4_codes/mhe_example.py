# Linguagem:        Python
# Autor:            Tiago Correa Prata
# Disponivel em:    
# § \url{https://github.com/TiagoPrata/MasterThesis/blob/master/4_codes/mhe_example.py} §

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import minimize

# model param
K = 1   # Gain
T = 2   # Time constant
n = 3   # number of state variables
model_params = {'K': K, 'T': T}
cov_process_disturb_w1 = 0.001
cov_process_disturb_w2 = 0.001
cov_process_disturb_w3 = 0.001
cov_process_disturb_w = np.diag([cov_process_disturb_w1, cov_process_disturb_w2, cov_process_disturb_w3])
cov_meas_noise_v1 = 0.01
cov_meas_noise_v = np.diag([cov_meas_noise_v1])

# Time settings
Ts = 0.5        # s
t_start = 0     # s
t_stop = 20     # s
t_array = np.linspace(t_start, t_stop-Ts, t_stop / Ts)
N = len(t_array)
t_mhe = 5
N_mhe = int(np.floor(t_mhe/Ts))
number_optim_vars = n*N_mhe

# Preallocation of arrays for storage
u_sim_array = t_array*0
x1_sim_array = t_array*0
x2_sim_array = t_array*0
x3_sim_array = t_array*0
y1_sim_array = t_array*0
x1_est_optim_plot_array = t_array*0
x2_est_optim_plot_array = t_array*0
x3_est_optim_plot_array = t_array*0

# Sim initialization
x1_sim_init = 2
x2_sim_init = 3
x1_sim_k = x1_sim_init
x2_sim_k = x2_sim_init

# MHE initialization
mhe_array = np.zeros(N_mhe)

x1_est_init_guess = 0
x2_est_init_guess = 0
x3_est_init_guess = 2
x1_est_optim_array = np.zeros(N_mhe) + x1_est_init_guess
x2_est_optim_array = np.zeros(N_mhe) + x2_est_init_guess
x3_est_optim_array = np.zeros(N_mhe) + x3_est_init_guess

x_est_guess_matrix = np.concatenate(([x1_est_optim_array], [x2_est_optim_array], [x3_est_optim_array]))

u_mhe_array = mhe_array * 0
y1_meas_mhe_array = mhe_array * 0

# Configuring continuous plotting
plt.ion()

def objective(x_est_matrix):
    # Reshaping matrix because it is flattened after minimine call
    x_est_matrix = x_est_matrix.reshape(3,N_mhe)

    K = model_params['K']
    T = model_params['T']
    Q = covars['Q']
    R = covars['R']

    J_km1 = 0

    for k in range(N_mhe-1):
        u_k = u_mhe_array[k]
        x_k = x_est_matrix[:,k]
        x1_k = x_k[0]
        x2_k = x_k[1]
        x3_k = x_k[2]
        h1_k = x1_k
        y1_meas_k = y1_meas_mhe_array[k]
        v1_k = y1_meas_k - h1_k
        v_k = v1_k

        if k<= N_mhe-1:
            x_kp1 = x_est_matrix[:,k+1]
            x1_kp1 = x_kp1[0]
            x2_kp1 = x_kp1[1]
            x3_kp1 = x_kp1[2]

            dx1_dt_k = x2_k
            dx2_dt_k = (-x2_k + K*u_k + x3_k)/T
            dx3_dt_k = 0
            f1_k = x1_k + Ts*dx1_dt_k
            f2_k = x2_k + Ts*dx2_dt_k
            f3_k = x3_k + Ts*dx3_dt_k
            w1_k = [x1_kp1 - f1_k]
            w2_k = [x2_kp1 - f2_k]
            w3_k = [x3_kp1 - f3_k]
            w_k = np.concatenate([w1_k, w2_k, w3_k]).T

        dJ_K = np.dot(np.dot(w_k.T, np.linalg.inv(Q)), w_k) + np.dot(np.dot(v_k.T, np.linalg.inv(R)), v_k)
        J_k = J_km1 + dJ_K

        # Time shift
        J_km1 = J_k
    
    return J_k

# Sim loop
for k in range(N):
    t_k = k*Ts

    # Process simulator
    if t_k < 2:
        u_k = 2
        d_k = 1

    # Change of u
    if t_k >=2:
        u_k = 2
    
    # Change of d
    if t_k >= 8:
        d_k = 1

    # Change of u
    if t_k >= 10:
        u_k = 6
    
    # Change of d
    if t_k >= 15:
        d_k = 2

    # derivatives
    dx1_sim_dt_k = x2_sim_k
    dx2_sim_dt_k = (-x2_sim_k + K*u_k + d_k)/T
    f1_sim_k = x1_sim_k + Ts*dx1_sim_dt_k
    f2_sim_k = x2_sim_k + Ts*dx2_sim_dt_k

    # Integration and adding disturbance
    w1_sim_k = np.sqrt(cov_process_disturb_w1) * np.random.rand()
    w2_sim_k = np.sqrt(cov_process_disturb_w2) * np.random.rand()
    x1_sim_kp1 = f1_sim_k + w1_sim_k
    x2_sim_kp1 = f2_sim_k + w2_sim_k
    
    # Calculating outpur and adding meas noise
    v1_sim_k = np.sqrt(cov_meas_noise_v1) * np.random.rand()
    y1_sim_k = x1_sim_k + v1_sim_k

    # Storage
    t_array[k] = t_k
    u_sim_array[k] = u_k
    x1_sim_array[k] = x1_sim_k
    x2_sim_array[k] = x2_sim_k
    x3_sim_array[k] = d_k
    y1_sim_array[k] = y1_sim_k

    # Preparing for time shift:
    x1_sim_k = x1_sim_kp1
    x2_sim_k = x2_sim_kp1

    # Updating u and y for use in MHE
    u_mhe_array = np.append(u_mhe_array[1:N_mhe], u_k)
    y1_meas_mhe_array = np.append(y1_meas_mhe_array[1:N_mhe], y1_sim_k)
    y_meas_mhe_array = [y1_meas_mhe_array]

    if k > N_mhe:
        Q = cov_process_disturb_w
        R = cov_meas_noise_v
        covars = {'Q': Q, 'R': R}

        # minimize initializtion
        x1_est_init_error = [0]
        x2_est_init_error = [0]
        x3_est_init_error = [0]
        x_est_init_error = np.concatenate(([x1_est_init_error], [x2_est_init_error], [x3_est_init_error]))

        # Guessed optim states:
        # Guessed present state (x_k) is needed to calculate optimal present meas
        # (y_k). Model is used in prediction:
        x1_km1 = x1_est_optim_array[N_mhe-1]
        x2_km1 = x2_est_optim_array[N_mhe-1]
        x3_km1 = x3_est_optim_array[N_mhe-1]

        dx1_dt_km1 = x2_km1
        dx2_dt_km1 = (-x2_km1 + K*u_k + x3_km1)/T
        dx3_dt_km1 = 0

        x1_pred_k = x1_km1 + Ts*dx1_dt_km1
        x2_pred_k = x2_km1 + Ts*dx2_dt_km1
        x3_pred_k = x3_km1 + Ts*dx3_dt_km1

        # Now, guessed optimal states are:
        x1_est_guess_array = np.append(x1_est_optim_array[1:N_mhe], x1_pred_k)
        x2_est_guess_array = np.append(x2_est_optim_array[1:N_mhe], x2_pred_k)
        x3_est_guess_array = np.append(x3_est_optim_array[1:N_mhe], x3_pred_k)
        # x_est_guess_matrix = np.concatenate((x1_est_guess_array, x2_est_guess_array, x3_est_guess_array))
        x_est_guess_matrix = [[x1_est_guess_array], [x2_est_guess_array], [x3_est_guess_array]]

        # Lower and upper limits of optim variables:
        x1_est_max = 100
        x2_est_max = 10
        x3_est_max = 10

        x1_est_min = -100
        x2_est_min = -10
        x3_est_min = -10

        # Creating a flatten array of bounderies
        # The bounderies must have the same size of x0 (x_est_guess_matrix)
        bnds = [(x1_est_min,x1_est_max)]*N_mhe + [(x2_est_min,x2_est_max)]*N_mhe + [(x3_est_min,x3_est_max)]*N_mhe

        x_est_optim_matrix_obj = minimize(objective, x_est_guess_matrix, method='SLSQP', bounds=bnds)
        # Reshaping matrix because it is flattened after minimine call
        x_est_optim_matrix = x_est_optim_matrix_obj.x.reshape(3,N_mhe)
        
        x1_est_optim_array = x_est_optim_matrix[0]
        x2_est_optim_array = x_est_optim_matrix[1]
        x3_est_optim_array = x_est_optim_matrix[2]

    x1_est_optim_plot_array[k] = x1_est_optim_array[-1]
    x2_est_optim_plot_array[k] = x2_est_optim_array[-1]
    x3_est_optim_plot_array[k] = x3_est_optim_array[-1]

    # Continuous plotting
    x_lim_array = [t_start, t_stop]
    if (k>0 and k<N):
        if k > N_mhe:
            plt.pause(1)
        else:
            plt.pause(0.1)
        
        plt.subplot(4,1,1)
        lineU, = plt.plot([t_array[k-1],t_array[k]],[u_sim_array[k-1],u_sim_array[k]],'b-o')
        if (k == 1):
            lineU.set_label('u')
            plt.legend()
            plt.xlim(x_lim_array)
            plt.ylim([0, 10])
            plt.title('u')

        plt.subplot(4,1,2)
        lineX1Sim, lineX1Est, = plt.plot([t_array[k-1],t_array[k]],[x1_est_optim_plot_array[k-1],x1_est_optim_plot_array[k]],'r-o',[t_array[k-1],t_array[k]],[x1_sim_array[k-1],x1_sim_array[k]],'b-o')
        if (k == 1):
            lineX1Sim.set_label('x1 sim')
            lineX1Est.set_label('x1 est')
            plt.legend()
            plt.xlim(x_lim_array)
            plt.ylim([0, 100])

        plt.subplot(4,1,3)
        lineX2Sim, lineX2Est, = plt.plot([t_array[k-1],t_array[k]],[x2_est_optim_plot_array[k-1],x2_est_optim_plot_array[k]],'r-o',[t_array[k-1],t_array[k]],[x2_sim_array[k-1],x2_sim_array[k]],'b-o')
        if (k == 1):
            lineX2Sim.set_label('x2 sim')
            lineX2Est.set_label('x2 est')
            plt.legend()
            plt.xlim(x_lim_array)
            plt.ylim([0, 10])

        plt.subplot(4,1,4)
        lineX3Sim, lineX3Est, = plt.plot([t_array[k-1],t_array[k]],[x3_est_optim_plot_array[k-1],x3_est_optim_plot_array[k]],'r-o',[t_array[k-1],t_array[k]],[x3_sim_array[k-1],x3_sim_array[k]],'b-o')
        if (k == 1):
            lineX3Sim.set_label('x3 sim')
            lineX3Est.set_label('x3 est')
            plt.legend()
            plt.xlim(x_lim_array)
            plt.ylim([0, 3])

        plt.draw()

plt.show(block=True)