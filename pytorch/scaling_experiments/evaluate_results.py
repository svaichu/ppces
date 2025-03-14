import argparse
import os, sys
import utils_plotting
import DataRun

def main(folder_path):
    #############################################
    ### Extracting data from files
    #############################################
    list_data = []
    for file in os.listdir(folder_path):
        if file.startswith("output_") and file.endswith(".log"):
            cur_file_path = os.path.join(folder_path, file)
            print(cur_file_path)
            tmp_obj = DataRun.DataRun()
            tmp_obj.parse_content(cur_file_path)
            list_data.append(tmp_obj)
    
    #############################################
    ### Plots nvidia-smi monitoring data
    #############################################
    path_plot_dir = os.path.join(folder_path, "plots")
    if not os.path.exists(path_plot_dir):
        os.makedirs(path_plot_dir)

    for d in list_data:
        d.plot_stats(path_plot_dir)

    #############################################
    ### Plots for overall / final stats
    #############################################
    unique_ngpus        = sorted(list(set([x.n_gpus for x in list_data])))

    features_to_plot        = ['execution_time', 'avg_time_per_epoch', 'validation_acc', 'test_acc']
    feature_labels          = ['Execution time [s]', 'Avg. Time per Epoch [s]', 'Validation Accurracy [%]', 'Test Accuracy [%]']
    feature_limits          = [None, None, 110, 110]
    feature_invert_speedup  = [False, False, True, True]
    list_data.sort(key=lambda x: x.n_gpus)

    for f_idx in range(len(features_to_plot)):
        cur_feature     = features_to_plot[f_idx]
        cur_label       = feature_labels[f_idx]
        cur_limit       = feature_limits[f_idx]
        cur_invert_sp   = feature_invert_speedup[f_idx]
        tgt_file_path   = os.path.join(path_plot_dir, "stats_overall_{}.png".format(cur_feature))
        cur_data        = [eval("x."+cur_feature) for x in list_data]
        
        utils_plotting.regular_plot(
            cur_data, 
            unique_ngpus, 
            invert_speedup=cur_invert_sp, 
            x_label="#GPUs",
            y_label=cur_label,
            title=f"{cur_label}",
            y_limit_top=cur_limit,
            target_path_png=tgt_file_path)
    
    #############################################
    ### Plots for each experiement and epochs
    #############################################

    features_to_plot        = ['arr_epoch_times', 'arr_validation_acc', 'arr_test_acc']
    feature_labels          = ['Epoch time [s]', 'Validation Accurracy [%]', 'Test Accuracy [%]']
    feature_limits          = [None, 110, 110]
    feature_invert_speedup  = [False, True, True]

    for item in list_data:
        for f_idx in range(len(features_to_plot)):
            cur_feature     = features_to_plot[f_idx]
            cur_label       = feature_labels[f_idx]
            cur_limit       = feature_limits[f_idx]
            cur_invert_sp   = feature_invert_speedup[f_idx]

            tgt_file_path   = os.path.join(path_plot_dir, "stats_{}n_{}tpn_{}gpus_{}.png".format(item.n_nodes, item.n_tasks_per_node, item.n_gpus, cur_feature))
            cur_data        = eval("item."+cur_feature)

            utils_plotting.regular_plot(
                cur_data, 
                [x+1 for x in range(len(cur_data))], 
                invert_speedup=cur_invert_sp, 
                x_label="Epoch",
                y_label=cur_label,
                title=f"{item.n_nodes}n_{item.n_tasks_per_node}tpn_{item.n_gpus}gpus - {cur_label}",
                y_limit_top=cur_limit,
                target_path_png=tgt_file_path)

if __name__== "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--source_dir", required=True, help="Source directory containing measurements and logs", type=str, default="<path>")
    args = ap.parse_args()

    # call main function
    main(args.source_dir)