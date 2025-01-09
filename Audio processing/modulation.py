import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile
from scipy.io.wavfile import write
from scipy.integrate import simps

#function for CTFT 
def CTFT(x_t, t, f):
    X_f = np.zeros(len(f), dtype=complex)
    for i, freq in enumerate(f):
        integrand = x_t * np.exp(-1j * 2 * np.pi * freq * t) #taking the time reversal thing in the orignal equation 
        X_f[i] = np.trapz(integrand, t)
    return X_f

#reading the audio file 
rate, data = wavfile.read('/home/abhay/Desktop/EC-211(Analog Communication)/skyfall_clip.wav')

#converting stereo to mono 
left_channel = data[:, 0]
right_channel = data[:, 1]
mono = left_channel + right_channel / 2
mono = mono.astype(np.int16)

#extracting the audio clip 
start = 13 * rate 
end   = 15 * rate
extracted_mono = mono[start:end]
time = np.arange(len(extracted_mono)) / rate

#normalizing audio clip 
max_value = np.max(np.abs(extracted_mono))
normalization_factor = 1 / max_value
print(normalization_factor)
normalized_mono = (extracted_mono * normalization_factor)

write("/home/abhay/Desktop/EC-211(Analog Communication)/normalized_mono.wav", rate, normalized_mono)

#generating modulation wave 
f_m = 100000 #100kHz
a_m = np.sin(2*np.pi*f_m*time)

#modulationg the signal 
A = (1 + normalized_mono) * a_m

plt.figure(figsize=(10,6))
plt.plot(time, A, color='green')
plt.title('Amplitude Modulation')
plt.xlabel('time')
plt.ylabel('a_m')
plt.legend()
plt.show()

#write("/home/abhay/Desktop/EC-211(Analog Communication)/modulated.wav", rate, A)

#fourier analysis of modulated wave 
f = np.linspace(0, 2000, 5000)
X_f = CTFT(A, time, f)

#plot of frequency vs phase 
plt.figure(figsize=(10,6))
plt.plot(f, np.abs(X_f), color='green')
plt.title('fourier Analysis of modulated wave')
plt.xlabel('frequency')
plt.ylabel('phase')
plt.legend()
plt.show()