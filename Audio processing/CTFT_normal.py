import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile
from scipy.io.wavfile import write
from scipy.integrate import simps

#function for CTFT 
def CTFT(x_t, t, f):
    X_f = np.zeros(len(f), dtype=complex)
    for i, freq in enumerate(f):
        integrand = x_t * np.exp(-1j * 2 * np.pi * freq * t)
        X_f[i] = np.trapz(integrand, t)
        print(X_f)
    return X_f


#reading the audio file 
rate, data = wavfile.read('/home/abhay/Desktop/EC-211(Analog Communication)/skyfall_clip.wav')
left_channel = data[:, 0]
right_channel = data[:, 1]
mono = left_channel + right_channel / 2

mono = mono.astype(np.int16)
start = 13  * rate 
end   = 15  * rate
extracted_mono = mono[start:end]
rev_mono = extracted_mono[::-1]

time = np.arange(len(rev_mono)) / rate

f = np.linspace(0, 1000, 5000)
X_f = CTFT(rev_mono, time, f)

plt.figure(figsize=(10, 6))

plt.plot(f, np.abs(X_f), color='green', label='fourier_transform')

plt.title('fourier transform')
plt.xlabel('frequency')
plt.ylabel('Amplitude')
plt.legend()
plt.show()
