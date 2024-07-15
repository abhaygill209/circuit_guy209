import matplotlib.pyplot as plt 
import numpy as np

# Define matrices and initial values
A = np.array([[1, 0], [0, 1]])
B = np.array([[1, 0], [0, 1]])
Q = np.array([[0.3, 0], [0, 0.3]])
H = np.array([[1, 0], [0, 1]])
R = np.array([[0.75, 0], [0, 0.6]])

c_pos = np.array([[0], [0]])
c_vel = np.array([[1], [1]])
p_pos = np.array([[0], [0]])
Z = np.array([[0.2], [0.3]])
c_cov = np.eye(2) * 0.1  # Initialize covariance matrix
p_cov = np.eye(2) * 0.1  # Initialize covariance matrix

x_pos = np.zeros(100)
y_pos = np.zeros(100)
r_x_pos = np.zeros(100)
r_y_pos = np.zeros(100)

for x in range(100):
    # Prediction step
    c_pos = np.dot(A, p_pos) + np.dot(B, c_vel)
    c_cov = np.dot(np.dot(A, p_cov), A.T) + Q
    
    # Update step
    delta_pos = Z - np.dot(H, c_pos)
    delta_cov = np.dot(np.dot(H, c_cov), H.T) + R
    delta_cov_inv = np.linalg.inv(delta_cov)
    
    Kalman = np.dot(np.dot(c_cov, H.T), delta_cov_inv)
    
    p_pos = c_pos + np.dot(Kalman, delta_pos)
    p_cov = c_cov - np.dot(Kalman, np.dot(H, c_cov))
    Z = np.add(Z, np.random.rand(2,1))
    
    r_x_pos[x] =  r_x_pos[x-1] + 1
    r_y_pos[x] =  r_y_pos[x-1] + 1
    x_pos[x] = p_pos[0, 0]
    y_pos[x] = p_pos[1, 0]

plt.plot(r_x_pos,r_y_pos)
plt.plot(x_pos, y_pos)
plt.xlabel('X Position')
plt.ylabel('Y Position')
plt.title('Kalman Filter Prediction')
plt.grid(True)
plt.legend
plt.show()

