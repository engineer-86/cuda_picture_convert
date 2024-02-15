import pandas as pd
import matplotlib.pyplot as plt
# import seaborn as sns
import os


def load_data(filepath):
    data = pd.read_csv(filepath)
    data['Timestamp'] = pd.to_datetime(data['Timestamp'], format='%H:%M:%S.%f')
    return data


def plot_wattage_over_time(data, save_path):
    plt.figure(figsize=(12, 7))

    unique_modes = data['Mode'].unique()
    unique_technologies = data['Technology'].unique()
    for mode in unique_modes:
        for tech in unique_technologies:
            subset = data[(data['Mode'] == mode) & (data['Technology'] == tech)]

            subset = subset.sort_values('Timestamp')
            plt.plot(subset['Timestamp'], subset['Power(Watts)'], marker='o', linestyle='-', label=f'{mode} ({tech})')
    plt.gcf().autofmt_xdate()
    plt.title('Wattage Over Time')
    plt.ylabel('Power (Watts)')
    # plt.yscale('log')
    plt.xlabel('Timestamp')
    plt.legend(title='Mode (Technology)')
    plt.tight_layout()
    plt.savefig(os.path.join(save_path, 'wattage_over_time.png'))
    plt.close()


def main():
    filepath = '../output/summary.csv'
    save_path = '../summaries/'
    data = load_data(filepath)
    plot_wattage_over_time(data, save_path)


if __name__ == "__main__":
    main()
