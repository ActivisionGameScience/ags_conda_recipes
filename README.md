=============================
 GAT Development Environment
=============================

Steps to set up a GAT development environment:

1) Download Miniconda installer (I used Miniconda-3.6.0-Linux_x86_64.sh) and install it::

    sh Miniconda-3.6.0-Linux_x86_64.sh

    edit your .bashrc and add ~/miniconda/bin to PATH
    close/reopen terminal 

3) Edit your .condarc and add our private channels::

    channels:
      - https://conda.binstar.org/ActivisionGameScience
      - defaults

2) Update everything::

    conda update --all
    conda install jinja2
    conda install git
    conda install conda-build
    conda install binstar
    

4) Clone the ``gat_conda_recipes`` repo (you probably already did since you're reading this)

5) Create a new environment using the platform-appropriate ``gatdevenv*.export`` file in the repo::

    conda create -n myenv --file agsdev_linux-64.export

NOTE for Spencer: the file ``getdevenv*.export`` was created by building (by hand) an
environment and then running::

    conda list --export > getdevenv_linux-64.export




Logged into binstar and created personal accounts
Created common "organization" called ActivisionGameScience
for each package:
    binstar register -u ActivisionGameScience ~/miniconda/conda-bld/linux-64/awesome-slugify-blahblah.tar.bz2
    binstar upload -u ActivisionGameScience ~/miniconda/conda-bld/linux-64/awesome-slugify-blahblah.tar.bz2

