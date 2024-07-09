import matplotlib.pyplot as plt
import os
import json
import numpy as np
from datetime import datetime

def plot_results(all_results):
    plt.figure(figsize=(10, 6))
    for directory, results_array in all_results.items():
        results_array = results_array[results_array[:, 0].argsort()]
        frequencies = results_array[:, 0]
        rms_values = results_array[:, 1]
        plt.loglog(frequencies, rms_values, marker='o', linestyle='-', label=directory)
    plt.title('Frequency vs RMS Value')
    plt.xlabel('Frequency (Hz)')
    plt.ylabel('RMS Value (m/s^2)')
    plt.grid(True, which='both', linestyle='--', linewidth=0.5)
    plt.legend()
    output_directory = './out'
    os.makedirs(output_directory, exist_ok=True)
    current_time = datetime.now().strftime("%H%M_%m%d_%Y")
    file_name = f'frequency_vs_rms_{current_time}.svg'
    plt.savefig(os.path.join(output_directory, file_name), format='svg')
    plt.show()

def load_processed_data(processed_file):
    with open(processed_file, 'r') as f:
        all_results = json.load(f)
        all_results = {k: np.array(v) for k, v in all_results.items()}
    return all_results
