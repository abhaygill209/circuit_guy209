import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile
from scipy.io.wavfile import write

#function for CTFT 
def CTFT(x_t, t, f):
    X_f = np.zeros(len(f), dtype=complex)
    for i, freq in enumerate(f):
        integrand = x_t * np.exp(-1j * 2 * np.pi * freq * t)
        X_f[i] = np.trapz(integrand, t)
        print(X_f[i])
    return X_f


#reading the audio file 
rate, data = wavfile.read('/home/abhay/Desktop/EC-211(Analog Communication)/skyfall_clip.wav')

left_channel = data[:, 0]
right_channel = data[:, 1]

#coverting audio to stereo audio
mono = left_channel + right_channel / 2

# Plot both channels on the same plot
plt.figure(figsize=(10, 6))
time = np.arange(len(data)) / rate

plt.plot(time, left_channel, color='blue', label='Left Channel')
plt.plot(time, right_channel, color='red', label='Right Channel')
plt.plot(time, mono, color='green', label='mono chanel')

plt.title('Stereo Audio Signal')
plt.xlabel('Time [s]')
plt.ylabel('Amplitude')
plt.legend()
plt.show()

#converting mono array to a audio signal 
mono = mono.astype(np.int16)
print(mono.dtype)
write("/home/abhay/Desktop/EC-211(Analog Communication)/output.wav", rate, mono)
start = 20*rate 
end   = 25*rate 
extracted_mono = mono[start:end]
time = np.arange(len(extracted_mono)) / rate
write("/home/abhay/Desktop/EC-211(Analog Communication)/ext_output.wav", rate, extracted_mono)

#for normalization 
max_value = np.max(np.abs(mono))
normalization_factor = 1 / max_value
print(normalization_factor)
normalized_mono = (mono * normalization_factor)
print(normalized_mono)

plt.figure(figsize=(10, 6))

plt.plot(time, normalized_mono, color='green', label='mono chanel')

plt.title('normalized_mono')
plt.xlabel('Time [s]')
plt.ylabel('Amplitude')
plt.legend()
plt.show()

write("/home/abhay/Desktop/EC-211(Analog Communication)/normalized_audio.wav", rate, normalized_mono)

#frequency range for fourier transform
f = np.linspace(0, 1000, 5000)
X_f = CTFT(extracted_mono, time, f)

plt.figure(figsize=(10, 6))

plt.plot(f, np.abs(X_f), color='green', label='fourier_transform')

plt.title('fourier transform')
plt.xlabel('frequency')
plt.ylabel('Amplitude')
plt.legend()
plt.show()

    

