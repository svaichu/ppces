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
dataset = datasets.load_iris()

# print desired information
print(f"Data set description:\n{dataset.DESCR}")
print(f"Shape of feature / training data: {dataset.data.shape}")
print(f"Shape of label data: {dataset.target.shape}")
print(f"Feature names: {dataset.feature_names}")
print(f"Target names: {dataset.target_names}")

# %% [markdown]
# ### Step 3: Train a KMeans clustering model
# Use the following parameters for the clustering model:
# - `n_clusters=3` (Idea: Check whether clustering will produce a similar result)
# - `init="k-means++"` (internal algorithm)
# - `random_state=42`

# %%
# create and intialize the clustering model
model = cluster.KMeans(n_clusters=3, init="k-means++", random_state=42)

# train / fit the model
elapsed_time = time.time()
model = model.fit(dataset.data)
elapsed_time = time.time() - elapsed_time

print(f"Elapsed time for preprocessing and training (original data): {elapsed_time} sec")

# %% [markdown]
# ### Step 4: Visualization of results + comparison to original classes
# As visualizing multi-dimensional data is challenging, apply the following:
# - Use PCA to shrink the dataset down to 2 dimensions while preserving most of the information (new 2D feature space)
# - Plot the samples in the new 2D space and color them by class using the original class (target) information
# - Plot the samples in the new 2D space and color them by class (cluster) using predicted clustering results
# - Can you spot any differences?

# %%
# transform data to new 2D feature space
pca = PCA(n_components=2)
X_pca = pca.fit(dataset.data).transform(dataset.data)

# define class colors
colors = ["navy", "turquoise", "darkorange"]

# =================================================================
# == plot original classes
# == using 2D feature space representation
# =================================================================

plt.figure()
for color, i, target_name in zip(colors, [0, 1, 2], dataset.target_names):
    plt.scatter(
        X_pca[dataset.target == i, 0], # x coordinates in new 2D feature space
        X_pca[dataset.target == i, 1], # y coordinates in new 2D feature space
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
y_pred = model.predict(dataset.data)

# plot
plt.figure()
for color, i, target_name in zip(colors, [0, 1, 2], ["Cluster 0", "Cluster 1", "Cluster 2"]):
    plt.scatter(
        X_pca[y_pred == i, 0], # x coordinates in new 2D feature space
        X_pca[y_pred == i, 1], # y coordinates in new 2D feature space
        color=color, alpha=0.8, lw=2,
        label=target_name
    )
plt.title("Clustered IRIS dataset classes (after applying PCA)")
plt.legend(loc="best", shadow=False, scatterpoints=1)
plt.show()


