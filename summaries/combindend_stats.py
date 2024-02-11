import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os
import glob

def load_and_process_csv(file_path):
    file_name = os.path.basename(file_path).split('.')[0]
    size_category = file_name.split('_')[-1]
    size_mapping = {
        'small': 'small (57 KB)',
        'medium': 'medium (113 KB)',
        'large': 'large (162 KB)'
    }
    size_description = size_mapping.get(size_category, size_category)
    df = pd.read_csv(file_path, delimiter=',')
    df['SizeCategory'] = size_description
    return df

def merge_data_frames(dfs):
    return pd.concat(dfs, ignore_index=True)

def create_bar_chart(df, output_dir):
    size_order = ['small (57 KB)', 'medium (113 KB)', 'large (162 KB)']
    df['SizeCategory'] = pd.Categorical(df['SizeCategory'], categories=size_order, ordered=True)
    df = df.sort_values('SizeCategory')

    plt.figure(figsize=(10, 6))
    sns.barplot(x='Technology', y='Times(s)', hue='SizeCategory', data=df, ci=None)
    plt.yscale('log')
    plt.title('Durchschnittliche Laufzeiten nach Technologie und Bildgröße (logarithmische Skala)')
    plt.ylabel('Durchschnittliche Zeit (s) [log]')
    plt.xlabel('Technologie')
    plt.legend(title='Bildgröße')
    plt.savefig(os.path.join(output_dir, 'average_times_by_size_with_details_log_scale.png'))
    plt.close()

def summarize_data(df, output_dir):

    summary = df.groupby(['SizeCategory', 'Technology', 'Mode'])['Times(s)'].agg(['mean', 'std']).reset_index()
    summary = summary.round(9)
    summary['mean'] = summary['mean'].map('{:.9f}'.format)
    summary['std'] = summary['std'].map('{:.9f}'.format)
    summary_csv_path = os.path.join(output_dir, 'combined_summary.csv')
    summary.to_csv(summary_csv_path, index=False)

base_dir = "C:\\Users\\arox\\Documents\\Coding\\cuda_hsv_blur\\summaries"
output_dir = os.path.join(base_dir, "output")

csv_files = glob.glob(os.path.join(base_dir, "*.csv"))

dfs = [load_and_process_csv(file) for file in csv_files]
merged_df = merge_data_frames(dfs)

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

create_bar_chart(merged_df, output_dir)
summarize_data(merged_df, output_dir)
print("Das Balkendiagramm mit Größenangaben (logarithmische Skala) und die kombinierte Zusammenfassung wurden erfolgreich erstellt.")
