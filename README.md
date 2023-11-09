
# Cryosparc to Relion script

## Implementation

Conda 4.10 is installed in the server; however a bug in this conda version recognizes python 3.10+ as python 3.1 and gives error. This bug is corrected in conda 4.11+ version; however as it is installed in the server (prob on /opt), users do not have access to update to 4.11. Therefore, a Miniconda3 installation is performed in user home

###  Install Miniconda 3

 Get Miniconda3 latest version and install it in a custom directory (~/software/miniconda3)
```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86.sh
bash Miniconda3-latest-Linux-x86.sh
```
Don't add the sugested line to `.bash.rc`

### Create pyem conda environment

Now create a new conda environment for pyem, and install the dependencies:
```bash
conda create -n pyem
conda activate pyem
conda install python=3.9 numpy scipy matplotlib seaborn numba pandas natsort
conda install -c conda-forge pyfftw healpy pathos 
```
 (do not use 3.10+ version of python). Put the environment  directory inside your home. You can use `conda env list` to check the directory

### Install pyem
```bash
git clone https://github.com/asarnow/pyem.git
cd pyem
pip install --no-dependencies -e .
```
It is recommended to add the pyem programs directory to your PATH environment
```bash
cd ~/bin
ln -s /path/to/pyem/*.py -t .
```

### Solve sourcing issues

As I had trouble with Conda 4.10, the source of the custom conda installation must be provided in the script. First, make a copy of `conda.sh` named `conda` 
```bash
cd /path/to/miniconda3/etc/profile.d
cp conda.sh conda
```
Now create the `csparc2star.sh` script inside `~/scripts` and make it executable using `chmod +x csparc2star.sh ` 


---

---
## Usage

Go to Relion>External
- Input
	- External executable: path to csparc2star.sh `~/scripts/csparc2star.sh`
- Params
	- projects: path to cryosparc project `path/to/project/P1`
	- job: whatever job you want to get the particles from (e.g. Homogeneous refinement, 2D class) `J123`
	- class: class number (optional)
	- image: Extract particles job `J122`
- Expected outputs
	- `External/job001/run.out`
			```CryoSPARC job directory:		  /home/cryosparc/projects/P1/J100
			Converting metadata file:		  External/job001/J100_010_particles.star
			Generating particle symlink: External/job001/J99 -> /home/cryosparc/projects/P1/J99 ```
- Files generated
	 Particle star file: `External/job001/J100_010_particles.star`

---

## Resources

- [Install pyem](https://github.com/asarnow/pyem/wiki/Install-pyem-with-Miniconda)
- [Original Script](https://obsidian-gallimimus-08c.notion.site/RELION-d0ed3a31d1ef44e581acb30a9f61f7e6#ded47a6d782048798139ea97833a9371)


---

