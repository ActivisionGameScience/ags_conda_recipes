Motivation
==========

If you are developing in C, C++, or python then you should 
use ``conda`` (https://github.com/conda/conda.git) for your
package/dependency management.  For other languages you might consider it
as well (fortran?).

To justify this, consider current package managers:

* python has ``pip`` + ``virtualenv``

* C/C++ has ``apt-get``, ``yum``, ``nuget``, ``homebrew``, etc

``pip`` works fine if you are only dealing with pure python packages.  However,
many of the best python packages (e.g. ``numpy``) are written in C, and
``pip`` is not a great tool for managing native binaries.

System-level package managers like ``apt-get`` and ``yum`` work
much better with native binaries, but they have serious drawbacks of their own: 

1) need root/admin access to install packages

2) libraries/versions are determined by distro
   (and further limited by your grumpy IT department)

3) your builds will be tightly coupled to specific platforms (or worse,
   to specific machines because nobody can remember how they were configured)

4) every OS has its own package manager

Point (2) is particularly nasty.  How many of us have been told that our deploy
environment is RHEL5 with python 2.4 and gcc 4.1?  Or RHEL6 with python 2.6
and gcc 4.4?  Working on those platforms is like slipping back in time
(and having your hands tied behind your back by IT).

Even if you create updated RPMs or DEBs, are you able to get 
them approved and deployed into production?  Doubtful.  
Even if yes, how many months will it take?
If you are starting a new project today, should it be subject to
the same environment that your 10-year-old project requires?

Point (3) is ugly if you need to deploy across many
environments.  Do you want to maintain separate builds for RHEL5, RHEL6,
Ubuntu12.04, and Ubuntu14.04?  It's already overwhelming enough to maintain 
Windows and Mac builds.

Point (4) is a problem even if you decide to just limit yourself
to Linux.  Which distro?  

Originally, ``pip`` also suffered from "system-level" lock-in, but
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
They are lightweight and easy to deploy like ``docker``, but
fully cross-platform (Linux, Windows, and Mac).

In short, you can be productive on even the most spartan 
RHEL5 box within minutes - no permission from IT is necessary.

``conda``'s package repository (analogous to ``pypi``) is called ``binstar``.  
You can maintain public and private packages on ``binstar``, and
can have organizations (similar to how github works).

For in-house packages that cannot leave your firewall you can maintain your
own package repository.  This can be as simple as a directory
containing tarballs.

These various possibilities can be mixed together because ``conda``
supports multiple simultaneous "channels".


Anaconda
--------

``Anaconda`` is a specific set of packages that is being
maintained by Continuum, Inc. (http://www.continuum.io).  Most of
these packages are free, but some (like ``mkl``) require a license.
You can use ``Anaconda`` or not.  The price (a few hundred dollars per
year per developer) is well-worth the saved time in our experience.
We are not associated with Continuum.

The examples below build on top of ``Anaconda``, but you don't
need to buy a license to do the tutorial.  After 30 days the ``mkl``,
``iopro``, and ``accelerate`` trials will simply expire and stop working.
If you don't need ``numpy`` then you won't miss it.


About this tutorial
-------------------

This tutorial covers all of these aspects with a full-fledged example.
It covers how to install ``conda``, then how to create an environment
that is a mix of ``Anaconda`` and our own builds of popular software
(i.e. stuff not in ``Anaconda`` that we wanted).

Our list of packages is growing weekly.  The recipes that we used to
build each package are contained in this repo.  Currently most recipes
only build in Linux, although we have added Windows support to some.  Mac
support is lagging.

Next we describe how to build a package from a recipe and upload it
to ``binstar``.

Finally, we describe 3 projects that we have posted on github.  These
are examples of how to use ``conda`` to manage your own code.  

The first two are C++ projects that build using ``cmake``.  One is an in-house library
that depends on a third-party library, and the other is an application
that depends on both.  We see how ``conda`` handles the dependency management.

The third is a python module that wraps the in-house library.  It builds
using the usual ``setuptools``, but we manage the packaging with ``conda``.


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

