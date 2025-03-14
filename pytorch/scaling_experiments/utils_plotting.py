import matplotlib.pyplot as plt
import numpy as np

def stacked_bar_plot(
    data, 
    legend_entries,
    x_axis_labels,
    invert_speedup = False,
    x_label = "",
    y_label = "",
    title = "",
    y_limit_top = None,
    target_path_png = None):

    overall_sum = [0] * len(data[0])
    for dat in data:
        overall_sum = [sum(x) for x in zip(overall_sum, dat)]

    if invert_speedup:
        tmp_speedup     = [x / overall_sum[0] for x in overall_sum]
    else:
        tmp_speedup     = [overall_sum[0] / x for x in overall_sum]
    
    fig = plt.figure(figsize=(16, 6),frameon=False)
    ax = fig.gca()
    ax.set_axisbelow(True)
    for x in range(len(data)):
        cur_data = data[x]
        if x == 0:
            ax.bar(x_axis_labels, cur_data)
        else:
            ax.bar(x_axis_labels, cur_data, bottom=data[x-1])
    if y_limit_top is not None:
        ax.set_ylim(top=y_limit_top)
    ax.grid(b=True, which='major', axis="both", linestyle='-', linewidth=0.4)
    ax.set_xlabel(x_label)
    ax.set_ylabel(y_label)
    ax.set_title(title)
    ax.legend(legend_entries)
    # Speedup
    ax2 = ax.twinx()
    ax2.set_ylabel('Speedup', color='red')
    ax2.plot(x_axis_labels, tmp_speedup, 'rx-')
    ax2.tick_params(axis='y', labelcolor='red')
    fig.savefig(target_path_png, dpi=None, facecolor='w', edgecolor='w', 
        format="png", transparent=False, bbox_inches='tight', pad_inches=0, metadata=None)
    plt.close(fig)

def regular_plot(
    data, 
    x_axis_labels,
    invert_speedup = False,
    x_label = "",
    y_label = "",
    title = "",
    y_limit_top = None,
    target_path_png = None):

    if invert_speedup:
        tmp_speedup     = [x / data[0] for x in data]
    else:
        tmp_speedup     = [data[0] / x for x in data]
    
    fig = plt.figure(figsize=(16, 6),frameon=False)
    ax = fig.gca()
    ax.set_axisbelow(True)
    ax.bar(x_axis_labels, data)
    if y_limit_top is not None:
        ax.set_ylim(top=y_limit_top)
    ax.grid(which='major', axis="both", linestyle='-', linewidth=0.4)
    ax.set_xlabel(x_label)
    ax.set_ylabel(y_label)
    ax.set_title(title)
    # Speedup
    ax2 = ax.twinx()
    ax2.set_ylabel('Speedup', color='red')
    ax2.plot(x_axis_labels, tmp_speedup, 'rx-')
    ax2.tick_params(axis='y', labelcolor='red')
    fig.savefig(target_path_png, dpi=None, facecolor='w', edgecolor='w', 
        format="png", transparent=False, bbox_inches='tight', pad_inches=0, metadata=None)
    plt.close(fig)

def regular_plot_multiple(
    data,
    data_labels,
    x_axis_labels,
    x_label = "",
    y_label = "",
    title = "",
    y_limit_top = None,
    target_path_png = None):

    fig = plt.figure(figsize=(16, 6),frameon=False)
    ax = fig.gca()
    ax.set_axisbelow(True)
    x = np.arange(len(x_axis_labels))
    cur_width_overall = 0.8
    cur_width = cur_width_overall / len(data)

    offset_start = cur_width_overall / -4

    for idx in range(len(data)):
        cur_data    = data[idx]
        cur_lbl     = data_labels[idx]
        ax.bar(x + offset_start + cur_width*idx, cur_data, cur_width, label=cur_lbl)

    ax.set_xticks(x)
    ax.set_xticklabels(x_axis_labels)

    if y_limit_top is not None:
        ax.set_ylim(top=y_limit_top)
    ax.grid(b=True, which='major', axis="both", linestyle='-', linewidth=0.4)
    ax.set_xlabel(x_label)
    ax.set_ylabel(y_label)
    ax.set_title(title)
    ax.legend()

    fig.savefig(target_path_png, dpi=None, facecolor='w', edgecolor='w', 
        format="png", transparent=False, bbox_inches='tight', pad_inches=0, metadata=None)
    plt.close(fig)