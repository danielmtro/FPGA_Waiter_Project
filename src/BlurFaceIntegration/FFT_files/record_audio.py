import pyaudio # pip install pyaudio
import matplotlib.pyplot as plt
import numpy as np
 
FORMAT = pyaudio.paInt16
CHANNELS = 1
RATE = 48000
CHUNK = 512
RECORD_SECONDS = 1
WAVE_OUTPUT_FILENAME = "recordedFile.wav"
device_index = 2
audio = pyaudio.PyAudio()

print("----------------------record device list---------------------")
info = audio.get_host_api_info_by_index(0)
numdevices = info.get('deviceCount')
for i in range(0, numdevices):
        if (audio.get_device_info_by_host_api_device_index(0, i).get('maxInputChannels')) > 0:
            print("Input Device id ", i, " - ", audio.get_device_info_by_host_api_device_index(0, i).get('name'))

print("-------------------------------------------------------------")
index = int(input()) # Can comment the above code out after you know this!

print("recording via index "+str(index))

stream = audio.open(format=FORMAT, channels=CHANNELS,
                rate=RATE, input=True,input_device_index = index,
                frames_per_buffer=CHUNK)
print ("recording started")
Recordframes = []
 
for i in range(0, 64): # 64x512 = 32768 samples (682.67ms)
    data = stream.read(CHUNK)
    Recordframes.append(data)
print ("recording stopped")
 
stream.stop_stream()
stream.close()
audio.terminate()

signal = []

for frame in Recordframes:
    for i in range(0,len(frame),2):
         signal.append(int.from_bytes(frame[i:i+2],byteorder="little", signed=True))

# Write whole recording to file
hexRecording = open("hex_recording.hex",'w')
for n in signal:
    hexRecording.write(f"{n&0xFFFF:04x}\n") # 16-bit

# Decimate (skip samples to increase resolution - SHOULD use low-pass filter!)
decimation = 1 # Change up to 32
decimated_sig = signal[-1024*decimation::decimation]

plt.plot(decimated_sig)
plt.show()

H = np.fft.fft(decimated_sig, 1024) # H[k] DFT of h[n]
mag = np.abs(H[:512])
freq = np.arange(0,512)/1024 * (48000/decimation)
plt.title("Frequency Response: 1024-point DFT $H[k]$")
plt.ylabel("Magnitude")
plt.xlabel("Frequency (Hz)")
plt.stem(freq, mag)
plt.grid()
plt.show()