import numpy as np
import matplotlib.pyplot as plt

def f_obj(x):
    return x**4.0 * 0.00232 - x**3.0 * 0.111 + x**2.0 * 1.80 - x * 11.6 + 34.4

x_min = 2
x_max = 22
N_x = 100
x_array = np.linspace(x_min, x_max, N_x)
f_array = np.dot(x_array, 0)

f_min = float('inf')
x_opt = float('-inf')

for i in range(len(x_array)):
    x = x_array[i]

    f = f_obj(x)

    if f <= f_min:
        f_min = f
        x_opt = x
    
    f_array[i] = f
    x_array[i] = x

print(f_min)
print(x_opt)
plt.plot(x_array, f_array)
plt.plot(x_opt, f_min, 'r*')
plt.show()