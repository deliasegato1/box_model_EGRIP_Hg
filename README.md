# Box model EGRIP Hg
In this folder are attached all files necessary to run the atmospheric mercury chemistry box model used in the article:

Segato D., Saiz-Lopez A., Mahajan A.S., Wang F., Corella J.P., Cuevas C.A., Erhardt T., Jensen C.M., Zeppenfeld C., Kjær H.A., Turetta C., Cairns W.R.L., Barbante C. and Spolaor A., Arctic mercury increased through the Last Glacial Termination due to climate warming, Nature Geoscience, in press

The box model is run using the KPP (Kinetic PreProcessor) model publicly available at https://people.cs.vt.edu/asandu/Software/Kpp/.

Instructions using Ubuntu terminal:
1) Install KPP following the documentation instructions
2) Go to KPP directory
```
cd $KPP_HOME
```
3) Clean the KPP installation, delete the KPP object files and all the examples with:
```
make clean
make distclean
```
4) Create the kpp executable with:
```
make
```
5) change directory to where box_model_update is stored
6) Run the model:
```
kpp box.kpp
```
7) Compile and run the Fortran90 code:
```
make -fMakefile_box
```
8) Run the executable file
```
./box.exe
```
