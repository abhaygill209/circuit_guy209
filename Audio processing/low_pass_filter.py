import scipy.io.wavfile
import math
from pydub import AudioSegment
import numpy as np
import matplotlib.pyplot as plt
samplerate,data= scipy.io.wavfile.read('/home/abhay/Desktop/EC-211(Analog Communication)/skyfall_clip.wav')

def prepare_audio(filename, duration, start_time):
    samplerate, data = scipy.io.wavfile.read(filename)
    time = np.linspace(start_time , duration, (duration-start_time)*samplerate)
    """plt.plot(time,data[:,0],linewidth = '0.15')
    plt.xlabel('Time (s)')
    plt.ylabel('Amplitude')
    plt.show()"""
    if(data.shape[1]==2):
      left_channel = data[:, 0]
      right_channel = data[:, 1]
      mono_data = left_channel + right_channel / 2
      mono_data = mono_data.astype(np.int16)
    #Normalization
      mono_data_M=mono_data.max()
      mono_data_m=mono_data.min()
      mono_data_N=(2/(mono_data_M-mono_data_m))*(mono_data-mono_data_M)+1
      data=mono_data_N[start_time*samplerate :duration*samplerate]
    else:
      data_M=mono_data.max()
      data_m=mono_data.min()
      data_N=(2/(mono_data_M-mono_data_m))*(mono_data-mono_data_M)+1
      data=data_N[start_time*samplerate :duration*samplerate]


    return time,samplerate,data

time,sr,mono_data=prepare_audio('/home/abhay/Desktop/EC-211(Analog Communication)/skyfall_clip.wav',15,13)

plt.plot(time,mono_data,linewidth = '0.15')
plt.xlabel('Time (s)')
plt.ylabel('Amplitude')
plt.show()

def FFT(x):
  #1D Cooley-Tukey FFT
  N=len(x)
  if(N==1):
    return x
  else:
    X_even = FFT(x[::2])
    X_odd = FFT(x[1::2])
    factor = \
    np.exp(-2j*np.pi*np.arange(N)/ N)
    print(X_odd)
    X = np.concatenate(\
    [X_even+factor[:int(N/2)]*X_odd,
             X_even+factor[int(N/2):]*X_odd])
    return X
