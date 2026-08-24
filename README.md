# Sewer-Linear-System-Identification
This is the Github repository of the paper "Integrator-Delay-Zero-based Modeling of Urban Drainage Systems" by Chuanning Wei, Trent Suzuki, and Margaret Chapman

The code has three formats: PCSWMM files that has suffix .inp, python files that has suffix .py, and matlab files that has suffix .m or .mat. We construct our sewer system map in the .inp files, all the computations are done in matlab files, and the python file uses pyswmm to read PCSWMM data and interact with PCSWMM model.

That is, you need to install pyswmm from their website https://www.pyswmm.org/. You will also need to have a license for PCSWMM if you want to have access to the details of the SWMM model. Next we introduce how to run the programs.

Running the program consists of three steps:
- Run the SWMM model to generate "system.out"
- Run pyswmm_interface.py to read "system.out" from its specified path. This saves a matlab data file hurricane_dw.mat.
- Run "main.m" to generate the plot in the paper.

(Before running the python script, you should type the command matlab.engine.shareEngine in your Matlab command line.)
(If you do not have a license for PCSWMM, you can neglect step 1 because the a sample "system.out" is provided, but you cannot make any changes to the PCSWMM model.)

## Structure of the Folders
The folders in this repository serve these functions:
- "Identification", consisting of .m files, contains our rework of "Analytical approximation of open-channel flow
for controller design" (Litrico, Fromion 2004), in which there are steps to obtain the IDZ parameters of simple conduits.
- "Simulation", also consisting of .m files, contains our IDZ-based, nonlinear model.
- "SWMM File" contains the SWMM model itself and some files associated with it. Specifically, a ".out" file contains the PCSWMM simulation output.
- "Main Steps", consistsing of .m files, partitions our main file into five steps.

Under the root folder, the files serve the following purposes:
- "pyswmm_interface.py" reads the .out file produced by the SWMM model and save all hydraulic variables in "hurricane_dw.mat".
- "main.m" is our main file.
- "save_system_data.m" helps "pyswmm_interface.py" save hydrualic variables.
- "hurricane_dw.mat" saves all hydraulic variables produced by our SWMM model "system.inp".

## Funding Acknowledgements
This work is based on the MASc thesis by C. Wei \cite{alfredThesis}. This work was supported in part by Computational Hydraulics Inc.’s Educational Grant Program for complimentary use of PCSWMM Prof 2D software. This work was supported in part by the Connaught Fund, University of Toronto, and by the Edward S. Rogers Sr. Department of Electrical and Computer Engineering, University of Toronto. We acknowledge the support of the Natural Sciences and Engineering Research Council of Canada (NSERC), [funding reference number RGPIN-2022-04140], [funding reference number DGECR-2022-00098].
Cette recherche a été financée par le Conseil de recherches en sciences naturelles et en génie du Canada (CRSNG), [numéro de référence RGPIN-2022-04140], [numéro de référence DGECR-2022-00098].
