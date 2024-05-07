# Author: Nicolas Legrand <nicolas.legrand@cfin.au.dk>

import papermill as pm
import os
import multiprocessing as mp


def report_HGF(
    subject,
    reportPath="/home/nicolas/git/HauntedHearts/reports",
):

    pm.execute_notebook(
        "/home/nicolas/git/HauntedHearts/code/HeartRateDiscrimination.ipynb",
        f"{reportPath}/{subject}.ipynb",
        parameters=dict(subject=subject, path="/home/nicolas/git/HauntedHearts/"),
    )
    command = f"jupyter nbconvert --to html {reportPath}/{subject}.ipynb --output {reportPath}/{subject.zfill(4)}.html"
    os.system(command)
    os.remove(f"{reportPath}/{subject}.ipynb")


if __name__ == "__main__":

    path = os.path.abspath(os.path.join(os.getcwd(), os.pardir))
    subjects = [sub[:-3] for sub in os.listdir(f"{path}/data/raw/")]
    subjects = [sub for sub in subjects if sub.isdigit()]

    pool = mp.Pool(processes=50)
    pool.map(report_HGF, subjects)
    pool.close()
    pool.join()