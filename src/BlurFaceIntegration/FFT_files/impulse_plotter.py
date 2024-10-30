import pandas as pd
import matplotlib.pyplot as plt

hex_values = [
    0x00000000, 0x00000014, 0x0000003f, 0x00000050, 0x00000000, 0xffffff0b, 0xfffffd56, 0xfffffb08,
    0xfffff8a1, 0xfffff6ee, 0xfffff6f3, 0xfffff9b5, 0x00000000, 0x00000a2d, 0x000017f4, 0x00002860,
    0x000039e3, 0x00004a8b, 0x0000584b, 0x0000615d, 0x00006488, 0x0000615d, 0x0000584b, 0x00004a8b,
    0x000039e3, 0x00002860, 0x000017f4, 0x00000a2d, 0x00000000, 0xfffff9b5, 0xfffff6f3, 0xfffff6ee,
    0xfffff8a1, 0xfffffb08, 0xfffffd56, 0xffffff0b, 0x00000000, 0x00000050, 0x0000003f, 0x00000014,
    0x00000000
]

def hex_to_decimal(hex_value):
    # Convert hex to signed 32-bit integer
    if hex_value & 0x80000000:
        hex_value -= 0x100000000
    # Convert to fixed-point with 16 fractional bits
    return hex_value / 2**16

decimal_values = [hex_to_decimal(value) for value in hex_values]
df = pd.DataFrame()
df['Impulse Response'] = decimal_values
fig, ax = plt.subplots()
df.plot(ax=ax)
ax.set_xlabel('Sample Index')
ax.set_ylabel('Impulse Response')
plt.show()
