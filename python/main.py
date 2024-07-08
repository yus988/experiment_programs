import pandas as pd
import numpy as np
from scipy.fft import fft, fftfreq
import os

def calculate_peak_frequency(ch4_data, samples=10000):
    # pandas Series を numpy 配列に変換
    ch4_data = ch4_data.to_numpy()
    
    # FFTを計算
    N = len(ch4_data)
    yf = fft(ch4_data)
    xf = fftfreq(N, 1 / samples)

    # 周波数のピークを検出
    peak_freq = xf[np.argmax(np.abs(yf))]

    return peak_freq

def calculate_rms(x_data, y_data, z_data, V2G=0.206):
    # pandas Series を numpy 配列に変換
    x_data = x_data.to_numpy()
    y_data = y_data.to_numpy()
    z_data = z_data.to_numpy()

    # 電圧値 -> Gに変換
    x_g = (x_data - x_data.mean()) / V2G
    y_g = (y_data - y_data.mean()) / V2G
    z_g = (z_data - z_data.mean()) / V2G

    # G -> m/s^2に変換
    g_to_m_s2 = 9.80665
    x_m_s2 = x_g * g_to_m_s2
    y_m_s2 = y_g * g_to_m_s2
    z_m_s2 = z_g * g_to_m_s2

    # RMS値を計算する
    n = len(x_m_s2)
    rms = np.sqrt((1/n) * np.sum((x_m_s2 - x_m_s2.mean())**2 + (y_m_s2 - y_m_s2.mean())**2 + (z_m_s2 - z_m_s2.mean())**2))

    return rms

def process_csv_files(directory):
    # ディレクトリ内の全CSVファイルを取得
    csv_files = [f for f in os.listdir(directory) if f.endswith('.csv')]
    
    # 結果を格納するリスト
    results = []
    
    for file_name in csv_files:
        file_path = os.path.join(directory, file_name)
        
        # CSVファイルの読み込み（ヘッダー行をスキップ）
        df = pd.read_csv(file_path, header=None, skiprows=20)
        
        # ch4のデータを抽出する
        ch4_data = df.iloc[1:, 4].astype(float)  # ch4のデータ（E列）

        # x, y, z（B, C, D列）のデータを抽出する
        x_data = df.iloc[1:, 1].astype(float)  # B列
        y_data = df.iloc[1:, 2].astype(float)  # C列
        z_data = df.iloc[1:, 3].astype(float)  # D列

        # 周波数のピークを計算
        peak_freq = calculate_peak_frequency(ch4_data)
        
        # 3軸のRMS値を計算
        rms = calculate_rms(x_data, y_data, z_data, V2G=0.100)  # V2Gは適宜調整してください

        # 結果をリストに追加
        results.append([peak_freq, rms])
    
    # リストを numpy 配列に変換
    results_array = np.array(results)

    return results_array

def main():
    # ディレクトリのパス
    directory = 'acc_data'  # 適宜ディレクトリパスを調整してください
    
    # CSVファイルを処理して結果を取得
    results_array = process_csv_files(directory)
    
    # 結果を出力
    print("Results (Frequency and RMS values):")
    print(results_array)

if __name__ == "__main__":
    main()
