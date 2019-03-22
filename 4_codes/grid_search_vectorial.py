import numpy as np 
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

x1_min = 0
x1_max = 2
N_x1 = 100
x1_array = np.linspace(x1_min, x1_max, N_x1)

x2_min = 1
x2_max = 3
N_x2 = 100
x2_array = np.linspace(x2_min, x2_max, N_x2)

f_min = float('inf')
x1_opt = float('-inf')
x2_opt = float('-inf')

f_matrix = np.zeros([len(x1_array), len(x2_array)])

def fun_obj(x1, x2):
    return (x1-1)**2 + (x2-2)**2 + 0.5

for k_x1 in range(len(x1_array)):
    x1 = x1_array[k_x1]
    for k_x2 in range(len(x2_array)):
        x2 = x2_array[k_x2]

        f = fun_obj(x1, x2)

        if not (x1-x2+1.5 <= 0):
            f = float('inf')
        
        if f <= f_min:
            f_min = f
            x1_opt = x1
            x2_opt = x2
        
        f_matrix[k_x1, k_x2] = f

print(f_min)
print(x1_opt)
print(x2_opt)

# fig = plt.figure()
# ax = Axes3D(fig)
# x, y = np.meshgrid(x1_array, x2_array)
# ax.plot_surface(x1_array, x2_array, f_matrix, rstride=1, cstride=1)
# plt.show()