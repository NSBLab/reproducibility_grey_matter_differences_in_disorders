import os
from brainsmash.mapgen.base import Base
import numpy as np
from wbplot import pscalar

# Print the current working directory
print("Current Working Directory:", os.getcwd())

# Load parcellated structural neuroimaging maps
thickness = np.loadtxt("LeftParcelMyelin.txt")

# Instantiate class and generate 10 surrogates
gen = Base(thickness, "LeftParcelGeodesicDistmat.txt")
surrogate_maps = gen(n=10)

output_filename = "dense_left_ex_gen_9.txt"
np.savetxt(output_filename, surrogates)


def vrange(x):
    return (np.percentile(x, 5), np.percentile(x, 95))

# Generate and save surrogate maps
for i in range(3):
    y = surrogate_maps[i]
    try:
        pscalar(
            file_out="/home/trangc/kg98/trangc/VBM/code/nulltest/pythonProject/surrogate_map_{}.png".format(i+1),  # Save as PNG files
            pscalars=y,
            orientation='landscape',
            hemisphere='left',
            vrange=vrange(y),
            cmap='magma'
        )
        print("Saved:", "surrogate_map_{}.png".format(i+1))
    except Exception as e:
        print("Error saving file:", e)

from brainsmash.mapgen.eval import base_fit

base_fit(
    x="LeftParcelMyelin.txt",
    D="LeftParcelGeodesicDistmat.txt",
    nsurr=1000,
    nh=25,  # these are default kwargs, but shown here for demonstration
    deltas=np.arange(0.1, 1, 0.1),
    pv=25)  # kwargs are passed to brainsmash.mapgen.base.Base