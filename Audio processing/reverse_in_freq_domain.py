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
left_channel = data[:, 0]
right_channel = data[:, 1]
mono = left_channel + right_channel / 2

mono = mono.astype(np.int16)

start = 20  * rate 
end   = 25 * rate
extracted_mono = mono[start:end]
time = np.arange(len(extracted_mono)) / rate

f = np.linspace(0, 1000, 5000)
X_f = CTFT(extracted_mono, time, f)
conj_X_f = X_f.conjugate()

plt.figure(figsize=(10, 6))

plt.plot(f, np.abs(conj_X_f), color='green', label='fourier_transform')

plt.title('fourier transform')
plt.xlabel('frequency')
plt.ylabel('Amplitude')
plt.legend()
plt.show()
