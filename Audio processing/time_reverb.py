import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile
from scipy.io.wavfile import write
from scipy.signal import convolve
from scipy.signal import resample

# function for CTFT 
def CTFT(x_t, t, f):
    X_f = np.zeros(len(f), dtype=complex)
    for i, freq in enumerate(f):
        integrand = x_t * np.exp(-1j * 2 * np.pi * freq * t) #taking the time reversal thing in the orignal equation 
        X_f[i] = np.trapz(integrand, t)
    return X_f

# reading the audio file 
rate, data = wavfile.read('/home/abhay/Desktop/EC-211(Analog Communication)/skyfall_clip.wav')

# converting stereo to mono 
left_channel = data[:, 0]
right_channel = data[:, 1]
mono = left_channel + right_channel / 2
mono = mono.astype(np.int16)

# extracting the audio clip 
start = 13 * rate 
end   = 15 * rate
extracted_mono = mono[start:end]
duration = len(extracted_mono) / rate
time = np.linspace(0, duration, len(extracted_mono))

# normalizing audio clip 
max_value = np.max(np.abs(extracted_mono))
normalization_factor = 1 / max_value
print(normalization_factor)
normalized_mono = (extracted_mono * normalization_factor)

# generating a reveb function 
F_rev = 500
decay = 0.3
Rev_fn = np.exp(-decay*time)*np.sin(2*np.pi*F_rev*time)

#convoluting rev signal and the main signal 
output = convolve(Rev_fn, normalized_mono, mode='same')
print(len(Rev_fn))

#normalizing 
output = output / np.max(np.abs(output))

f = np.linspace(0,1000,5000)
X_f = CTFT(output, time, f)

plt.figure(figsize=(10, 6))

plt.plot(f, np.abs(X_f), color='green', label='')

plt.title('reverbing signal in time domain')
plt.xlabel('frequency')
plt.ylabel('Amplitude')
plt.legend()
plt.show()



