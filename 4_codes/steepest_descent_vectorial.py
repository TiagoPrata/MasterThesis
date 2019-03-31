# Linguagem:        Python
# Autor:            Tiago Correa Prata
# Disponivel em:    
# § \url{https://github.com/TiagoPrata/MasterThesis/blob/master/4_codes/steepest_descent_vectorial.py} §

import numpy as np

# definindo a funcao custo descrita na § \cref{eq:steepest_decent_vectorial_example_fobj} §
def f_obj(x):
    return (x[0]-1)**2 + (x[1]-2)**2 + 0.5

x_guess = np.array([0., 1.]).T          # x0 estimado
x_k = x_guess
N = 10000       # limite de tentativas
abs_df = 1e-4   # valor do criterio de parada, como na § \cref{eq:steepest_decent_vectorial_example_df} §

for k in range(1, N-1):
    G_k = np.array([2*(x_k[0]-1), 2*(x_k[1]-2)]).T
    K = 0.1
    dx_k = -K * G_k
    x_kp1 = x_k + dx_k
    f_k = f_obj(x_k)
    f_kp1 = f_obj(x_kp1)

    # implementacao do criterio de parada da § \cref{eq:steepest_decent_vectorial_example_stop} §
    df = f_kp1 - f_k
    x_k = x_kp1
    if abs(df) < abs_df:
        break

x_opt = x_kp1
f_min = f_obj(x_opt)

print(k)
print(x_opt)
print(f_min)