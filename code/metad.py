import sys
from pathlib import Path

import arviz as az
import pandas as pd
from metadPy.bayesian import hmetad
from metadPy.utils import discreteRatings

sub = str(sys.argv[1])
path = Path("/home/nicolas/git/HauntedHearts/")

# Load subject level behavior file
try:
    behavior_df = pd.read_csv(Path(path, "data", "raw", f"{sub}HRD", f"{sub}HRD_final.txt"))

    # Drop trials with NaN in confidence rating
    behavior_df = behavior_df[~behavior_df.Confidence.isna()]

except:
    print(f"Subject {sub}: data not found")

# Ratings discretization
try:
    new_ratings, _ = discreteRatings(
        behavior_df.Confidence.to_numpy(), verbose=False
    )
    behavior_df.loc[:, "discrete_confidence"] = new_ratings
except ValueError:
    print(f"Subject {sub} - Cannot discretize ratings")

# meta-d'
# Code columns for Bayesian modelling
behavior_df["Stimuli"] = behavior_df.copy()["Alpha"] > 0
behavior_df["Responses"] = behavior_df["Decision"] == "More"
behavior_df["Accuracy"] = (
    behavior_df["Stimuli"] & behavior_df["Responses"]
) | (~behavior_df["Stimuli"] & ~behavior_df["Responses"])

# Fit meta-d' model
_, trace = hmetad(
    data=behavior_df,
    stimuli="Stimuli",
    accuracy="Accuracy",
    confidence="discrete_confidence",
    nRatings=4,
    cores=1,
)
az.to_netcdf(trace, Path(path, "data", "metad", f"{sub}_meyad.nc"))