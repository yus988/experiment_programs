import os
from data_processing import process_all_data
from plot_results import plot_results, load_processed_data

def main():
    parent_directory = 'acc_data'
    processed_file = os.path.join(parent_directory, 'processed_results.json')
    
    if os.path.exists(processed_file):
        all_results = load_processed_data(processed_file)
    else:
        all_results = process_all_data(parent_directory)
    
    plot_results(all_results)

if __name__ == "__main__":
    main()
