import os
from data_processing import process_all_data
from plot_results import plot_results, load_processed_data

# 凡例の名前と色を定義
plot_styles = {
    "Duo 2": {"color": "red", "label": "Duo 2"},
    "Duo": {"color": "green", "label": "Duo"},
    "Solo": {"color": "blue", "label": "Solo"}
}

def main():
    parent_directory = 'acc_data'
    
    for title_directory in os.listdir(parent_directory):
        title_dir_path = os.path.join(parent_directory, title_directory)
        processed_file = os.path.join(title_dir_path, 'processed_results.json')
    
        if os.path.exists(processed_file):
            all_results = load_processed_data(processed_file)
        else:
            all_results = process_all_data(parent_directory)
        
        # plot_styles が定義されていない場合には引数に渡さない
        if 'plot_styles' in globals():
            plot_results(all_results, plot_styles)
        else:
            plot_results(all_results)

if __name__ == "__main__":
    main()
