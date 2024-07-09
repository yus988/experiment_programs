import pandas as pd
import numpy as np
from scipy.fft import fft, fftfreq
import os
import json

def calculate_peak_frequency(ch4_data, samples):
    ch4_data = ch4_data.to_numpy()
    N = len(ch4_data)
    yf = fft(ch4_data)
    xf = fftfreq(N, 1 / samples)
    peak_freq = xf[np.argmax(np.abs(yf))]
    return peak_freq

def calculate_rms(x_data, y_data, z_data, V2G=0.206):
    x_data = x_data.to_numpy()
    y_data = y_data.to_numpy()
    z_data = z_data.to_numpy()
    x_g = (x_data - x_data.mean()) / V2G
    y_g = (y_data - y_data.mean()) / V2G
    z_g = (z_data - z_data.mean()) / V2G
    g_to_m_s2 = 9.80665
    x_m_s2 = x_g * g_to_m_s2
    y_m_s2 = x_g * g_to_m_s2
    z_m_s2 = x_g * g_to_m_s2
    n = len(x_m_s2)
    rms = np.sqrt((1/n) * np.sum((x_m_s2 - x_m_s2.mean())**2 + (y_m_s2 - y_m_s2.mean())**2 + (z_m_s2 - z_m_s2.mean())**2))
    return rms

def process_csv_files(directory, samples):
    csv_files = [f for f in os.listdir(directory) if f.endswith('.csv')]
    results = []
    for file_name in csv_files:
        file_path = os.path.join(directory, file_name)
        df = pd.read_csv(file_path, header=None, skiprows=20)
        ch4_data = df.iloc[1:, 4].astype(float)
        x_data = df.iloc[1:, 1].astype(float)
        y_data = df.iloc[1:, 2].astype(float)
        z_data = df.iloc[1:, 3].astype(float)
        peak_freq = calculate_peak_frequency(ch4_data, samples)
        rms = calculate_rms(x_data, y_data, z_data, V2G=0.100)
        results.append([peak_freq, rms])
    results_array = np.array(results)
    return results_array

def process_all_data(parent_directory):
    all_results = {}
    for title_directory in os.listdir(parent_directory):
        title_dir_path = os.path.join(parent_directory, title_directory)
        if os.path.isdir(title_dir_path):
            all_results[title_directory] = {}
            for sub_dir in os.listdir(title_dir_path):
                sub_dir_path = os.path.join(title_dir_path, sub_dir)
                if os.path.isdir(sub_dir_path):
                    results = []
                    for nested_dir in os.listdir(sub_dir_path):
                        nested_dir_path = os.path.join(sub_dir_path, nested_dir)
                        if os.path.isdir(nested_dir_path) and nested_dir == '1e3':
                            results_array = process_csv_files(nested_dir_path, samples=1000)
                            results.extend(results_array)
                        elif nested_dir.endswith('.csv'):
                            results_array = process_csv_files(sub_dir_path, samples=10000)
                            results.extend(results_array)
                    all_results[title_directory][sub_dir] = np.array(results)
    
    output_file = os.path.join(title_dir_path, 'processed_results.json')
    with open(output_file, 'w') as f:
        json.dump({k: {sk: sv.tolist() for sk, sv in v.items()} for k, v in all_results.items()}, f)
    return all_results
