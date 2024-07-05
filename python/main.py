# csvファイルから加速度のRMS値を計算し、グラブを描画
# グラフは横軸周波数、縦軸 m/s^2、ドットと直線
import pandas as pd
import numpy as np
from scipy.fft import fft, fftfreq
import os

# CSVファイルのパス
file_path = 'acc_data/tek0009.csv'  # 適宜ファイルパスを調整してください

# CSVファイルの読み込み（ヘッダー行をスキップ）
df = pd.read_csv(file_path, header=None, skiprows=21)

# ch4のデータを抽出する
ch4_data = df.iloc[1:, 4].astype(float)  # ch4のデータ（E列）

# サンプリングレートを推定する（ここでは仮に1000Hzとする）
sampling_rate = 10000  # 例として仮の値

# Numpy配列に変換
ch4_data = ch4_data.to_numpy()

# FFTを計算
N = len(ch4_data)
yf = fft(ch4_data)
xf = fftfreq(N, 1 / sampling_rate)

# 周波数のピークを検出
peak_freq = xf[np.argmax(np.abs(yf))]

print(f"Peak Frequency: {peak_freq} Hz")


