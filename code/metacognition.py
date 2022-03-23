import arviz as az
import numpyro
import pandas as pd
from metadPy.utils import discreteRatings

BIDS_path = "/mnt/scratch/BIDS/"

numpyro.set_host_device_count(2)


def metad(input_data):

    ns = input_data[0]
    sub = input_data[1]

    # Load subject level behavior file
    try:
        behavior_df = pd.read_csv(
            f"{BIDS_path}/{sub}/ses-session1/beh/{sub}_ses-session1_task-hrd_beh.tsv",
            sep="\t",
            na_values="n/a",
        )

        # Drop trial with NaN in confidence rating
        behavior_df = behavior_df[~behavior_df.Confidence.isna()]

        hrd_tasks = behavior_df.HRD_version.unique()
    except:
        print(f"Subject {sub}: data not found")
        return

    for task in hrd_tasks:

        if task != "BreathHold":
            mods = ["Intero", "Extero"]
        else:
            mods = ["breathFree", "breathHold"]

        for mod in mods:

            try:

                if task != "BreathHold":
                    metacognition_df = behavior_df[
                        (behavior_df.Modality == mod)
                        & (behavior_df.HRD_version == task)
                    ].copy()  # Filter the subjec level df
                else:
                    metacognition_df = behavior_df[
                        (behavior_df.BreathCondition == mod)
                        & (behavior_df.HRD_version == task)
                    ].copy()  # Filter the subjec level df

            except:
                print(f"Subject {sub} - Cannot find data")

            # Ratings discretization
            try:
                new_ratings, _ = discreteRatings(
                    metacognition_df.Confidence.to_numpy(), verbose=False
                )
                metacognition_df.loc[:, "discrete_confidence"] = new_ratings
            except ValueError:
                print(f"Subject {sub} - Cannot discretize ratings")

            # meta-d'
            try:
                # Code columns for Bayesian modelling
                metacognition_df["Stimuli"] = metacognition_df.copy()["Alpha"] > 0
                metacognition_df["Responses"] = metacognition_df["Decision"] == "More"
                metacognition_df["Accuracy"] = (
                    metacognition_df["Stimuli"] & metacognition_df["Responses"]
                ) | (~metacognition_df["Stimuli"] & ~metacognition_df["Responses"])

                model, traces = metacognition_df.hmetad(
                    stimuli="Stimuli",
                    accuracy="Accuracy",
                    confidence="discrete_confidence",
                    nRatings=4,
                    padding=True,
                )
                meta_d = az.summary(traces, var_names=["meta_d"])["mean"][0]
            except:
                meta_d = "n/a"
                print(f"Subject {sub} - Cannot perform meta-d modelling")

            if task != "BreathHold":

                ns.df = ns.df.append(
                    {
                        "participant_id": sub,
                        "modality": mod,
                        "task": task,
                        "breath_condition": "n/a",
                        "bayesian_meta_d": meta_d,
                    },
                    ignore_index=True,
                )
            else:

                ns.df = ns.df.append(
                    {
                        "participant_id": sub,
                        "modality": "Intero",
                        "breath_condition": mod,
                        "task": task,
                        "bayesian_meta_d": meta_d,
                    },
                    ignore_index=True,
                )