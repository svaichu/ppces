import os, sys
import statistics as st
import pandas as pd
import numpy as np
import math
import matplotlib.pyplot as plt

F_SIZE = 14
plt.rc('font', size=F_SIZE)             # controls default text sizes
plt.rc('axes', titlesize=F_SIZE)        # fontsize of the axes title
plt.rc('axes', labelsize=F_SIZE)        # fontsize of the x and y labels
plt.rc('xtick', labelsize=F_SIZE)       # fontsize of the tick labels
plt.rc('ytick', labelsize=F_SIZE)       # fontsize of the tick labels
plt.rc('legend', fontsize=12)           # legend fontsize
plt.rc('figure', titlesize=F_SIZE)      # fontsize of the figure title

class DataRun():
    def __init__(self):
        self.framework = "dummy"
        self.n_nodes = 1
        self.n_tasks_per_node = 1
        self.n_gpus = 1

        self.execution_time = -1
        self.avg_time_per_epoch = -1
        self.validation_acc = -1
        self.test_acc = -1

        self.arr_epoch_times = []
        self.arr_validation_acc = []
        self.arr_test_acc = []

        self.data_frame_smi = None
    
    def parse_content(self, file_path):
        file_name               = os.path.basename(file_path)
        cur_arr                 = file_name.split("_")
        self.framework          = cur_arr[1]
        self.n_nodes            = int(cur_arr[2][:-1])
        self.n_tasks_per_node   = int(cur_arr[3][:-3])
        self.n_gpus             = self.n_nodes * self.n_tasks_per_node

        # Load data from file itself
        with open(file_path) as fp:
            for line in fp:
                if "Epoch" in line and "Elapsed" in line: # Output from Pytorch
                    spl = line.split()
                    self.arr_epoch_times.append(float(spl[-4].strip()))
                    self.arr_validation_acc.append(float(spl[-1].strip()) * 100.0)
                    continue
                elif "Test Acc" in line: # Output from Pytorch
                    spl = line.split()
                    self.arr_test_acc.append(float(spl[-1].strip()) * 100.0)
        
        if len(self.arr_epoch_times) > 0:
            self.avg_time_per_epoch     = st.mean(self.arr_epoch_times) # excluding first
            self.execution_time         = sum(self.arr_epoch_times)
        else:
            self.avg_time_per_epoch     = 0
            self.execution_time         = 0

        if len(self.arr_validation_acc) > 0:
            self.validation_acc = self.arr_validation_acc[-1]
        if len(self.arr_test_acc) > 0:
            self.test_acc = self.arr_test_acc[-1]

        # Load data from stats file
        file_path_monitoring = file_path.replace("output_pytorch", "gpu_monitoring")
        df = pd.read_csv(file_path_monitoring)

        # clean col names and format values
        col_names = [x for x in df.columns]
        for coln in col_names:
            df = df.rename(columns={coln: coln.strip()})
        
        tmp_n_rows = df.shape[0]
        tmp_n_cols = df.shape[1]

        for col in range(tmp_n_cols):
            do_repl = False
            if df.columns[col] == 'utilization.gpu [%]' or df.columns[col] == 'utilization.memory [%]':
                do_repl = True
                repl_char = "%"
            elif df.columns[col] == 'power.draw [W]':
                do_repl = True
                repl_char = "W"
            if do_repl:
                for row in range(tmp_n_rows):
                    tmp_val = str(df.iat[row, col])
                    spl     = tmp_val.split(repl_char)
                    tmp_val = float(spl[0].strip())
                    df.iat[row, col] = tmp_val

        self.data_frame_smi = df

    def plot_stats(self, path_plot_dir):
        cols_to_plot    = ['utilization.gpu [%]', 'power.draw [W]', 'temperature.gpu', 'utilization.memory [%]']
        y_lims_to_set   = [100.0, None, None, 100.0]
        name_suffix     = ['utilization.gpu', 'power.draw', 'temperature.gpu', 'utilization.memory']

        vals_idx        = self.data_frame_smi['index'].tolist()
        max_gpus        = max(vals_idx)+1

        # color map
        n_colors    = max_gpus
        cm          = plt.get_cmap('gist_rainbow')
        colors      = [cm(1.*i/n_colors) for i in range(n_colors)]

        for col_idx in range(len(cols_to_plot)):
            col             = cols_to_plot[col_idx]
            tgt_file_path   = os.path.join(path_plot_dir, "monitoring_{}n_{}tpn_{}gpus_{}.png".format(self.n_nodes, self.n_tasks_per_node, self.n_gpus, name_suffix[col_idx]))
            # access data
            array_data      = [[] for x in range(max_gpus)]
            cur_vals        = self.data_frame_smi[col].tolist()
            cur_idx         = 0
            for idx in range(len(cur_vals)):
                array_data[cur_idx].append(cur_vals[idx])
                cur_idx += 1
                if(cur_idx == max_gpus):
                    cur_idx = 0

            fig = plt.figure(figsize=(16, 6),frameon=False)
            ax = fig.gca()

            for idx in range(max_gpus):
                ax.plot(np.arange(len(array_data[idx])), array_data[idx], alpha=0.6, label='GPU {}'.format(idx), color=colors[idx])
                # ax.fill_between(np.arange(len(array_data[idx])), array_data[idx], alpha=0.6, label='GPU {}'.format(idx), color=colors[idx])
            cur_y_lim = y_lims_to_set[col_idx]
            ax.set_ylim(bottom=0)
            if cur_y_lim is not None:
                cur_max_val = cur_y_lim
            else:
                cur_max_val = max([max(x) for x in array_data])
            cur_max_val *= 1.2
            ax.set_ylim(top=cur_max_val)
            ax.legend(fancybox=True, shadow=False, loc='upper right', ncol=math.ceil(max_gpus/2))
            ax.grid(which='major', axis="both", linestyle='-', linewidth=1)
            ax.grid(which='minor', axis="both", linestyle='-', linewidth=0.4)
            ax.set_xlabel("Time [s]")
            ax.set_ylabel(col)
            ax.set_title("{} GPUs: {} - {}".format(self.framework, self.n_gpus, col))
            
            fig.savefig(tgt_file_path, dpi=None, facecolor='w', edgecolor='w', 
                format="png", transparent=False, bbox_inches='tight', pad_inches=0, metadata=None)
            plt.close(fig)
