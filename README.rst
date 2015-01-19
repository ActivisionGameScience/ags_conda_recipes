Motivation
==========

If you are developing in C, C++, or python then you should strongly
consider switching to ``conda`` (https://github.com/conda/conda.git) for your
package/dependency management (note: ``conda`` 
may be ideal for other languages as well, e.g. fortran).

To motivate ``conda`` let us compare it to current package managers:

* python has ``pip`` + ``virtualenv``

* C/C++ has ``apt-get``, ``yum``, ``nuget``, ``homebrew``, etc

``pip`` works fine if you are only dealing with pure python code.  However,
many of the most useful packages (e.g. ``numpy``) are written in C.
``pip`` is a terrible C/C++ build tool
(same for managing prebuilt binaries, although ``.whl`` is an
improvement).

System-level package managers like ``apt-get`` and ``yum`` are language-agnostic
and hence don't suffer from these limitations.  However, they have serious
drawbacks of their own:

1) need root/admin access to install packages

2) libraries/versions are determined by distro
   (and further limited by your grumpy IT department)

3) you builds will be glued to specific platforms

4) different package management for every OS

Point (2) is particularly nasty.  How many of us have been told that our deploy
environment is RHEL5 with python 2.4 and gcc 4.1?  Or RHEL6 with python 2.6
and gcc 4.4?  

Even if you create the perfect package, are you able to get it approved?  
How many months will it take?  What if you are starting a new project today, but also must
maintain a project from 10 years ago?  Should your project
today suffer from 10-year-old limitations?

Point (3) is particularly bad if you need to deploy across many
environments.  Do you want to maintain a separate build for RHEL5, RHEL6,
Ubuntu12.04, and Ubuntu14.04?  It's already overwhelming enough to maintain 
separate Windows and Mac builds.

Point (4) is a problem even if you decide to just limit your builds
to Linux.  Which distro?  

Originally, ``pip`` also suffered from this "system-level" lock-in, but
``virtualenv`` solved the problem with its notion of "environments".  
Unfortunately, this only works for pure python code.


Conda
-----

``conda`` keeps the good aspects of each of these package managers
and jettisons the bad.  It handles native libraries,
but avoids the system-wide trap.  No root access is necessary.  
Think "``pip`` + ``virtualenv``, but for native libraries as well".

Like ``virtualenv``, ``conda`` also has a notion of "environment".
You can have as many environments as you like (perhaps one per project).
They are lightweight and easy to deploy (like ``docker``), but
the idea is fully cross-platform (Linux, Windows, and Mac).

You can be productive and deploy modern code on even the most spartan 
RHEL5 box within minutes - no permission from IT is necessary.

The package repository (analogous to ``pypi``) is called ``binstar``.  
You can maintain public and private packages on ``binstar``, and
can have organizations (similar to github).

For sensitive packages you can maintain your own repository in a
directory somewhere behind your firewall (perhaps served up using
a simple webserver).  

``conda`` has a notion of "channels", so you can mix and match these
options.  The tutorial below shows a full-fledged example using
everything simultaneously.


Installation
============

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

