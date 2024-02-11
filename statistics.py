import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import sys
import os


def create_summary_plot(input_file_path, output_dir):
    df = pd.read_csv(input_file_path, delimiter=',')
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    plt.figure(figsize=(8, 4))
    means = df.groupby(['Technology', 'Mode'])['Times(s)'].mean().reset_index()
    sns.barplot(x='Technology', y='Times(s)', hue='Mode', data=means)
    plt.title('Mittelwerte der Laufzeiten für alle Technologien')
    plt.yscale('log')
    plt.savefig(os.path.join(output_dir, 'all_means.png'))
    plt.close()


def create_csv_summary(input_file_path, output_dir):
    df = pd.read_csv(input_file_path, delimiter=',')
    summary_table = df.groupby(['Technology', 'Mode'])['Times(s)'].agg(['mean', 'std']).reset_index()
    summary_table = summary_table.round(9)
    summary_table['mean'] = summary_table['mean'].map('{:.9f}'.format)
    summary_table['std'] = summary_table['std'].map('{:.9f}'.format)
    summary_csv_path = os.path.join(output_dir, 'stats.csv')
    summary_table.to_csv(summary_csv_path, index=False)


def create_dot_plot(input_file_path, output_dir):
    df = pd.read_csv(input_file_path, delimiter=',')
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    plt.figure(figsize=(10, 6))
    sns.stripplot(x='Technology', y='Times(s)', hue='Mode', data=df, jitter=True)

    plt.yscale('log')
    plt.xlabel('Technology')
    plt.ylabel('Time (s)')
    plt.title('Dot Plot der Laufzeiten für alle Technologien')
    plt.legend()
    plt.savefig(os.path.join(output_dir, 'dot_plot.png'))
    plt.close()


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("First argument: CSV input file\n Second argument: output path.")
        sys.exit(1)

    _input_file_path = sys.argv[1]
    _output_dir = sys.argv[2]
    create_summary_plot(_input_file_path, _output_dir)
    create_dot_plot(_input_file_path, _output_dir)
    create_csv_summary(_input_file_path, _output_dir)
