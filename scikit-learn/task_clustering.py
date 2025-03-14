# %% [markdown]
# # PPCES - Task: Clustering Iris Dataset
# In this task, participants should apply clustering techniques to the iris toy dataset from scikit-learn. The task involves
# - Loading the dataset
# - Train the clustering model
# - For visualization: Applying a dimensionality reduction with Principal Component Analysis (PCA)

# %% [markdown]
# ### Step 1: Load desired Python modules

# %%
import time
import matplotlib.pyplot as plt

from sklearn import cluster, datasets
from sklearn.decomposition import PCA

# %% [markdown]
# ### Step 2: Loading the dataset
# Load the dataset and print out the following information
# - Description of the dataset
# - Array shape of the feature data that is used for training the model
# - Array shape of the label / target data (Note: clustering will not require that info as it only focuses on the feature distances to find a pattern)
# - List of the feature names
# - List of the target names

# %%
# load the dataset
# TODO

# print desired information
# TODO

# %% [markdown]
# ### Step 3: Train a KMeans clustering model
# Use the following parameters for the clustering model:
# - `n_clusters=3` (Idea: Check whether clustering will produce a similar result)
# - `init="k-means++"` (internal algorithm)
# - `random_state=42`

# %%
# create and intialize the clustering model
# TODO

# train / fit the model
# TODO

# %% [markdown]
# ### Step 4: Visualization of results + comparison to original classes
# As visualizing multi-dimensional data is challenging, apply the following:
# - Use PCA to shrink the dataset down to 2 dimensions while preserving most of the information (new 2D feature space)
# - Plot the samples in the new 2D space and color them by class using the original class (target) information
# - Plot the samples in the new 2D space and color them by class (cluster) using predicted clustering results
# - Can you spot any differences?

# %%
# transform data to new 2D feature space
# TODO

# define class colors
colors = ["navy", "turquoise", "darkorange"]

# =================================================================
# == plot original classes
# == using 2D feature space representation
# =================================================================
# TODO
plt.figure()
for color, i, target_name in zip(colors, [0, 1, 2], ???):
    plt.scatter(
        ???, # x coordinates in new 2D feature space
        ???, # y coordinates in new 2D feature space
        color=color, alpha=0.8, lw=2,
        label=target_name
    )
plt.title("Original IRIS dataset classes (after applying PCA)")
plt.legend(loc="best", shadow=False, scatterpoints=1)

# =================================================================
# == plot classes resulting from clustering
# == using 2D feature space representation
# =================================================================

# get cluster numbers for the different data samples
# TODO

# plot
plt.figure()
for color, i, target_name in zip(colors, [0, 1, 2], ["Cluster 0", "Cluster 1", "Cluster 2"]):
    plt.scatter(
        ???, # x coordinates in new 2D feature space
        ???, # y coordinates in new 2D feature space
        color=color, alpha=0.8, lw=2,
        label=target_name
    )
plt.title("Clustered IRIS dataset classes (after applying PCA)")
plt.legend(loc="best", shadow=False, scatterpoints=1)
plt.show()


