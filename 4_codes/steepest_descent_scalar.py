def f_obj(x):
    a4 = 0.00232
    a3 = -0.111
    a2 = 1.80
    a1 = -11.6
    a0 = 34.4

    return a4*x**4 + a3*x**3 + a2*x**2 + a1*x + a0

x_guess = 10
x_k = x_guess
h = 1e-4
N = 1000
abs_df_spec = 1e-4

for k in range(1, N-1):
    gradient_num_k = (f_obj(x_k+h)-f_obj(x_k-h))/(2*h)
    dx_k = gradient_num_k
    x_kp1 = x_k + dx_k
    f_k = f_obj(x_k)
    f_kp1 = f_obj(x_kp1)
    abs_df = abs(f_kp1 - f_k)
    x_k = x_kp1
    if abs_df < abs_df_spec:
        break

x_opt = x_kp1
f_min = f_obj(x_opt)

print(x_opt)
print(f_min)
print(abs_df)