import matplotlib.pyplot as plt
import os
import json
import numpy as np
from datetime import datetime

def plot_results(all_results, plot_styles=None):
    for title_directory, subdir_results in all_results.items():
        plt.figure(figsize=(10, 6))

        # plot_styles が定義されていない場合のデフォルト設定
        if plot_styles is None:
            plot_styles = {}
            colors = plt.cm.tab10.colors  # デフォルトの色を使用
            default_labels = list(subdir_results.keys())  # ディレクトリ名をラベルとして使用
            for i, name in enumerate(subdir_results.keys()):
                if i < len(colors):
                    plot_styles[name] = {"label": default_labels[i] if i < len(default_labels) else name, "color": colors[i]}

        # plot_styles の順番でプロットする
        for name, style in plot_styles.items():
            if name in subdir_results:
                results_array = subdir_results[name]
                results_array = results_array[results_array[:, 0].argsort()]
                frequencies = results_array[:, 0]
                rms_values = results_array[:, 1]
                
                plt.plot(frequencies, rms_values, marker='o', linestyle='-', label=style["label"], color=style["color"])
        
        plt.xscale('log')
        plt.yscale('linear')
        plt.xlim(10, 470)
        plt.ylim(1, 100)
        plt.title(f'Frequency vs RMS Value ({title_directory})')
        plt.xlabel('Frequency (Hz)')
        plt.ylabel('RMS Value (m/s^2)')
        plt.grid(True, which='both', linestyle='--', linewidth=0.5)
        
        # x軸の目盛りをカスタマイズ
        ax = plt.gca()
        ax.set_xticks([10, 50, 100, 200, 300, 400])
        ax.get_xaxis().set_major_formatter(plt.ScalarFormatter())
        
        plt.legend()
        output_directory = './out'
        os.makedirs(output_directory, exist_ok=True)
        current_time = datetime.now().strftime("%H%M_%m%d_%Y")
        file_name = f'{title_directory}_{current_time}.svg'
        plt.savefig(os.path.join(output_directory, file_name), format='svg')
        plt.show()

def load_processed_data(processed_file):
    with open(processed_file, 'r') as f:
        all_results = json.load(f)
        all_results = {k: {sk: np.array(sv) for sk, sv in v.items()} for k, v in all_results.items()}
    return all_results
