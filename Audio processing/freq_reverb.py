import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile
from scipy.io.wavfile import write
from scipy.signal import convolve
from scipy.signal import resample

# function for CTFT 
def FFT(x_t, t, f):
    X_f = np.zeros(len(f), dtype=complex)
    for i, freq in enumerate(f):
        integrand = x_t * np.exp(-1j * 2 * np.pi * freq * t) #taking the time reversal thing in the orignal equation 
        X_f[i] = np.trapz(integrand, t)
    return X_f

# Reverse fourier transform 
def RFT(X_f, t, f):
    out = np.zeros(len(t), dtype=complex)
    for i, time in enumerate(t):
        integrand = X_f * np.exp(1j * 2 * np.pi * f * time) #taking the time reversal thing in the orignal equation 
        out[i] = np.trapz(integrand, f) 
    return out    

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
time = np.arange(len(extracted_mono)) / rate

# normalizing audio clip 
max_value = np.max(np.abs(extracted_mono))
normalization_factor = 1 / max_value
print(normalization_factor)
normalized_mono = (extracted_mono * normalization_factor)

f = np.linspace(0, 1000, 5000) # range for analysing frequency 

# generating a reveb function 
F_rev = 500
decay = 0.3
Rev_fn = np.exp(-1*decay*time)*np.sin(2*np.pi*F_rev*time)
max_value = np.max(np.abs(max_value))
norm_rev_fn = Rev_fn / max_value

#making a fourier transform for both the signals and multiplying them 
X_1 = FFT(normalized_mono, time, f)
X_2 = FFT(norm_rev_fn, time, f)

X_3 = X_1 * X_2

# ploting fourier transform 
plt.figure(figsize=(10, 6))

plt.plot(f, np.abs(X_3), color='green', label='')

plt.title('reverbing signal in freq domain')
plt.xlabel('frequency')
plt.ylabel('Amplitude')
plt.legend()
plt.show()