# csvファイルから加速度のRMS値を計算し、グラブを描画
# グラフは横軸周波数、縦軸 m/s^2、ドットと直線
import pandas as pd
import numpy as np
from scipy.fft import fft, fftfreq
import os

# CSVファイルのパス
file_path = 'acc_data/tek0029.csv'  # 適宜ファイルパスを調整してください

# CSVファイルの読み込み（ヘッダー行をスキップ）
df = pd.read_csv(file_path, header=None, skiprows=20)

# ch4のデータを抽出する
ch4_data = df.iloc[1:, 4].astype(float)  # ch4のデータ（E列）

samples = 10000 
# Numpy配列に変換
ch4_data = ch4_data.to_numpy()

# FFTを計算
N = len(ch4_data)
yf = fft(ch4_data)
xf = fftfreq(N, 1 / samples)

# 周波数のピークを検出
peak_freq = xf[np.argmax(np.abs(yf))]

print(f"Peak Frequency: {peak_freq} Hz")



# 電圧値 -> Gに変換
# 0.206: MMA7361LC 1.5G MODE
# 0.800: MMA7361LC 1.5G MODE
# 0.1: ADXL354 8G MODE
V2G = 0.100

# x, y, z（B, C, D列）のデータを抽出する
x_data = df.iloc[1:, 1].astype(float)  # B列
y_data = df.iloc[1:, 2].astype(float)  # C列
z_data = df.iloc[1:, 3].astype(float)  # D列
# print("x_data:", x_data.head())

x_g = x_data / V2G
y_g = y_data / V2G
z_g = z_data / V2G

# G -> m/s^2に変換
g_to_m_s2 = 9.80665
x_m_s2 = x_g * g_to_m_s2
y_m_s2 = y_g * g_to_m_s2
z_m_s2 = z_g * g_to_m_s2

# 各軸の平均を計算
mu_x = np.mean(x_m_s2)
mu_y = np.mean(y_m_s2)
mu_z = np.mean(z_m_s2)

# RMS値を計算する
n = len(x_m_s2)
rms = np.sqrt((1/n) * np.sum((x_m_s2 - mu_x)**2 + (y_m_s2 - mu_y)**2 + (z_m_s2 - mu_z)**2))

print(f"Average RMS Value: {rms:.4f} m/s^2")