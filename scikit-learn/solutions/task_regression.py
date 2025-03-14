# %% [markdown]
# # PPCES - Task: Regression with California Housing Dataset
# In this task, participants should apply preprocessing and regression techniques to the California housing (real world) dataset from scikit-learn, which lists several houses, specific attributes of the houses and their prices. The task involves
# - Loading the dataset
# - Applying preprocessing techniques such as feature standardization
# - Training and evaluating the regression model
# - Visualization results and scores

# %% [markdown]
# ### Step 1: Load desired Python modules

# %%
import time
import matplotlib.pyplot as plt

from sklearn import datasets, preprocessing, metrics
from sklearn.ensemble import RandomForestRegressor
from sklearn.svm import SVR
from sklearn.model_selection import train_test_split

# %% [markdown]
# ### Step 2: Loading the dataset
# Load the dataset and print out the following information
# - Description of the dataset
# - Array shape of the feature data that is used for training the model
# - Array shape of the label / target data
# - List of the feature names
# - List of the target names

# %%
# load the dataset
dataset = datasets.fetch_california_housing()

# print desired information
print(f"Data set description:\n{dataset.DESCR}")
print(f"Shape of feature / training data: {dataset.data.shape}")
print(f"Shape of label data: {dataset.target.shape}")
print(f"Feature names: {dataset.feature_names}")
print(f"Target names: {dataset.target_names}")

# %% [markdown]
# ### Step 3: Data preprocessing
# Run the following:
# - Determine the min, max and avg values per feature
#   - You should see that the value ranges are quite different per feature
#   - Some models work better if all features have a similar order of magnitude
# - Split the data into train and test splits
# - Apply standardization to the training data split
#   - Note: of course you also need to apply the same standardization to the test split later!

# %%
# determine min and max values per feature
min_vals = list(dataset.data.min(axis=0))
avg_vals = list(dataset.data.mean(axis=0))
max_vals = list(dataset.data.max(axis=0))

for i in range(len(min_vals)):
    print(f"{dataset.feature_names[i]:15}:\tMin\t{min_vals[i]:8.3f}\tAvg\t{avg_vals[i]:8.3f}\tMax\t{max_vals[i]:8.3f}")

# split data into train and test split (Use 20% test data)
X_train, X_test, y_train, y_test = train_test_split(dataset.data, dataset.target, test_size=0.20, random_state=42, shuffle=True)

# create a StandardScaler
scaler = preprocessing.StandardScaler()

# scale training data
scaler = scaler.fit(X_train)
X_train = scaler.transform(X_train)
print(f"Scaler mean values (based on training set):\n{scaler.mean_}")
print(f"Scaler scale values (based on training set):\n{scaler.scale_}")

# dont forget to apply the same scaler to the test data split
X_test = scaler.transform(X_test)

# %% [markdown]
# ### Step 4: Train a Support Vector Regression (SVR) or RandomForest Regression model
# For SVR, use the following parameters:
# - `C=1.0` (regularization parameter)
# - `epsilon=0.2` (specifies the epsilon-tube within which no penalty is associated in the training loss function with points predicted within a distance epsilon from the actual value)
# 
# For RandomForest, use the following parameters:
# - `n_estimators=10` (Number of different trees)
# - `random_state=42`
# - `max_depth=None` (depth of the trees, `None` will figure it out on its own)
# - You can also play around with number of trees and depth

# %%
# create and intialize the model
model = SVR(C=1.0, epsilon=0.2)
# model = RandomForestRegressor(n_estimators=10, max_depth=None, random_state=42)

# train / fit the model
elapsed_time = time.time()
model = model.fit(X_train, y_train)
elapsed_time = time.time() - elapsed_time

print(f"Elapsed time for training: {elapsed_time} sec")

# %% [markdown]
# ### Step 5: Evaluate the model using typical scoring functions
# To evaluate the model performance, do the following:
# - Predict the housing prices for the test split with the trained model (applying on unseen data)
# - Plot both original (ground truth) and predicted values
# - Determine `r2_score`, `mean_absolute_error` and `mean_absolute_percentage_error` for the prediction
#   - Note: There are multiple scoring functions for different purposes. You can find more information here: https://scikit-learn.org/stable/modules/model_evaluation.html

# %%
# predict housing prices for test split
y_pred = model.predict(X_test)

# Plot both original (ground truth) and predicted values. Limited to the first 100 values to see differences 
plt.figure()
plt.plot(y_test[:100]*100_000, color="blue", label="ground truth")
plt.plot(y_pred[:100]*100_000, color="red", label="predicted")
plt.legend()
plt.xlabel("House")
plt.ylabel("Price in USD")
plt.show()

# determine r2 and mean_absolute_error
val_r2  = metrics.r2_score(y_test, y_pred)
val_mae = metrics.mean_absolute_error(y_test, y_pred)
val_mape = metrics.mean_absolute_percentage_error(y_test, y_pred)

# print results
print(f"R2: {val_r2}")
print(f"MAE: {val_mae*100_000} whereas mean house prices are {y_test.mean()*100_000}")
print(f"MAPE: {val_mape}")


