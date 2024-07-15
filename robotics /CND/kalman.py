import matplotlib.pyplot as plt 
import numpy as np
import math 

A = np.array([[1,0],[0,1]])
B = np.array([[1,0],[0,1]])
Q = np.array([[0.3,0],[0,0.3]])
H = np.array([[1,0],[0,1]])
R = np.array([[0.75,0],[0,0.6]])

c_pos = np.array([[0],[0]])
c_vel = np.array([[1],[1]])
p_pos = np.array([[0],[0]])
Z = np.array([[0],[0]])
Z = np.add(Z, np.array([[0.2],[0.3]]))
c_cov = np.array([[0,0],[0,0]])
p_cov = np.array([[0.1,0],[0,0.1]])

x_pos = np.zeros(10)
y_pos = np.zeros(10)

for x in range(10):
	y =np.multiply[B,c_vel]
	c_pos = np.add(p_pos,y)
	c_cov = np.add(p_cov,Q)

	delta_pos = np.subtract(Z, c_pos)
	delta_cov = np.add(p_cov, R)
	delta_cov_inv = np.linalg.inv(delta_cov)

	Kalman = np.multiply(c_cov, delta_cov_inv)
 	
	y = np.multiply(Kalman, delta_pos)
	p_pos = np.add(c_pos, y)
	y = np.multiply(Kalman, c_cov)
	p_cov = np.subtract(c_cov, y)
	x_pos[x] = p_pos[0]
	y_pos[x] = p_pos[1]
	
plt.plot(x_pos,y_pos)
plt.show()
