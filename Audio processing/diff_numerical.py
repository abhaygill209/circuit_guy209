import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile
from scipy.io.wavfile import write
from scipy.integrate import simps

def CTFT(x_t, t, f):
    X_f = np.zeros(len(f), dtype=complex)
    for i, freq in enumerate(f):
        integrand = x_t * np.exp(-1j * 2 * np.pi * freq * t) #taking the time reversal thing in the orignal equation 
        X_f[i] = np.trapz(integrand, t)
    return X_f

#reading the audio file 
rate, data = wavfile.read('/home/abhay/Desktop/EC-211(Analog Communication)/skyfall_clip.wav')
left_channel = data[:, 0]
right_channel = data[:, 1]
mono = left_channel + right_channel / 2

mono = mono.astype(np.int16)

start = 13  * rate 
end   = 15 * rate
extracted_mono = mono[start:end]
time = np.arange(len(extracted_mono)) / rate

max_value = np.max(np.abs(extracted_mono))
normalization_factor = 1 / max_value
print(normalization_factor)
normalized_mono = (extracted_mono * normalization_factor)

diff = (normalized_mono[:-1] - normalized_mono[1:]) * rate 
print (normalized_mono)
time = np.delete(time, -1)

f = np.linspace(0, 1000, 5000)
X_f = CTFT(diff, time, f)

plt.figure(figsize=(10, 6))

plt.plot(f, np.abs(X_f), color='green')
plt.title('fourier analysis of Differentiated audio signal')
plt.xlabel('frequency')
plt.ylabel('amplitude')
plt.legend()
plt.show()

write("/home/abhay/Desktop/EC-211(Analog Communication)/diff_num.wav", rate, diff)
