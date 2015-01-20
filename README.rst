Motivation
==========

If you are developing in C, C++, or python then you should 
use ``conda`` (https://github.com/conda/conda.git) for your
package (dependency) management.  For other languages you might consider it
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

2) packages are limited to what is available in the distro
   (and further limited by your grumpy IT department)

3) your builds will be tightly coupled to specific platforms 

4) every OS has its own package manager

Point (2) is particularly nasty.  How many of us have been told that our deploy
environment is RHEL5 with python 2.4 and gcc 4.1?  Or RHEL6 with python 2.6
and gcc 4.4?  Working on those platforms is like slipping back in time
(and having your hands tied behind your back).

Even if you create updated RPMs or DEBs, are you able to get 
them approved and deployed into production?  Doubtful.  
Even if so, how many months and signatures will it take?
If you are starting a new project today, should it be subject to
the same environment that a different 10-year-old project requires?

Point (3) is ugly if you need to deploy across many
environments.  Do you want to maintain separate builds for RHEL5, RHEL6,
Ubuntu12.04, and Ubuntu14.04?  Maintaining Windows and Mac builds is
already difficult enough.

Point (4) is a problem even for the Linux-only crowd.  Which distro?  

As far as system-level lock-in is concerned, ``pip`` is only somewhat
better.  Originally we were installing python packages in our global
``site-packages``, but now at least we have ``virtualenv``.  With
"environments" we are freed from system lock-in.  Unfortunately
it only works *well* for pure python code.


What is conda?
--------------

``conda`` keeps the good aspects of each of these package managers
and jettisons the bad.  It handles native libraries without
being locked in at the system level.  No root access is necessary.  

Like ``virtualenv``, ``conda`` also has a notion of "environment".
You can have as many environments as you like (perhaps one per project).
They are lightweight and easy to deploy like ``docker``, but
fully cross-platform (Linux, Windows, and Mac).

In short, you can be productive on a spartan
RHEL5 box within minutes - no permission from IT is necessary.

``conda``'s package repository (analogous to ``pypi``) is called ``binstar``.  
Continuum, Inc., maintains many public packages on there.  ``binstar`` also 
allows you to maintain your own public and private packages, and
group yourselves into *organizations* (similar to how github works).

For in-house packages that cannot leave your firewall you can maintain your
own package repository.  This can be as simple as a directory
containing tarballs.

These various possibilities can be mixed together because ``conda``
supports multiple simultaneous "channels".


What is Anaconda?
-----------------

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

This tutorial describes these aspects with a full-fledged example.
It covers how to install ``conda``, then how to create an environment
that is a mix of ``Anaconda`` and our own (Activision) builds of popular software
(i.e. stuff not in ``Anaconda`` that we wanted).

Our list of packages is growing steadily.  The recipes that we use to
build each are contained in this repo (that you are reading now).  Currently most recipes
only build in Linux, although we have added Windows support to some.  Mac
support is lagging.

Our environment should take about 5 minutes of typing and 30 minutes
of waiting (to download) before it is installed.  After this, 
we will pick a package at random and
demonstrate how we originally built it (from a recipe) and uploaded it to ``binstar``.

Finally, we describe 3 projects that we have posted on github.  These
are examples of how to use ``conda`` to manage your own "in-house" codebase.  

The first is a C++ library that builds using ``cmake``.  It is a library
that depends on a third-party library.  The second is a C++ application that depends on
both.  We see how ``conda`` handles the dependency management.

The third is a python module that wraps the in-house library, i.e. exposes a python API
around a raw C binary.  Again we manage the packaging with ``conda``.


First steps: install conda
==========================

First, start from the most spartan machine that you can find.  Really punish yourself.
I started with this barebones CentOS5 vagrant box:  
http://tag1consulting.com/files/centos-5.9-x86-64-minimal.box.

It has no ``git`` and no ``java`` (let alone ``javac``, ``maven``, and ``ant``).  
It doesn't even have ``vim``!  It's missing ``tmux`` and ``zsh``, 
and the system python is 2.4.  You can forget about any of your favorite python libraries.

I hate this machine (note: I was forced to work on a machine
like this at a former job).

Let's turn this machine into a joy.  Download the ``Miniconda`` installer 
from http://conda.pydata.org/miniconda.html and run it::

    sh Miniconda-3.7.0-Linux_x86_64.sh

If you allowed it to modify your ``.bashrc`` then close and reopen your terminal.  
Otherwise you'll always have to enable the "root" environment manually::

    export PATH=~/miniconda/bin:$PATH

Either way, typing ``where python`` should show ``~/miniconda/bin/python`` (or
wherever you installed it).

Only conda utility packages are allowed in the root environment.  Don't pollute
it with anything else.  Your real environments will live below ``~/miniconda/envs``.

If you want to use python 3 then I recommend having a separate ``conda``
instance for it.  For example, you can download the ``Miniconda3`` installer
and set up a separate root environment in ``/some/other/path/miniconda3``.

Now edit your ``~/.condarc`` file and add both our ActivisionGameScience channel and the default
``Anaconda`` channels::

    channels:
      - https://conda.binstar.org/ActivisionGameScience
      - defaults

Remember that spacing is important in YAML files (indents are 2 spaces)!  Since
our ActivisionGameScience channel is listed first, packages will be pulled from
there preferentially.

Now update everything in your root environment (and install some more utility packages)::

    conda update --all
    conda install jinja2 git conda-build binstar
    

Try out our environment!  
------------------------

You are ready to try out our ActivisionGameScience dev environment.  Even if you
don't like it, it should give you an idea of the possibilities.

Clone the current repository (that you are reading)::

    git clone https://github.com/ActivisionGameScience/ags_conda_recipes.git

or, alternatively, just grab the file::

    ags_dev-0.1.0-linux-64.export

This contains an exact specification of packages that we like.  Some of
them come from ``Anaconda``, but many of them come from our own channel.
Now you can create  your own ``agsdev`` environment (name it whatever
you want)::

    conda create -n agsdev --file agsdev-0.1.0-linux-64.export

Go for a walk to let it download (takes about 30 minutes).
Future installs will be almost instantaneous because ``conda`` keeps
a cache of downloaded tarballs.

You can "activate" the environment like this::

    source activate agsdev

Go ahead, test some things out!  You'll notice that everything is
there that I complained about (``git``, ``cmake``, ``vim``, ``tmux``, ``zsh``,
``java``, ``javac``, ``ant``, ``mvn``, and much more!).

You can deactivate the environment like this (this puts you back into the root environment)::

    source deactivate

For future reference, if you build an environment that you like
then you can always export its specification like this (with
the environment activated)::

    conda list --export > myenv-linux-64.export


How we built and uploaded packages to binstar
=============================================

In order to build a package for ``conda`` you'll need to write
a "recipe".  Some recipes are so trivial that they can be
auto-generated by ``conda``.  Pure python libraries
from ``pypi``, for example, can usually have their recipes auto-generated
like this::

    conda skeleton pypi tweepy

This creates a directory, ``tweepy/``, that contains
the following files::

    ``meta.yaml``
    ``build.sh``
    ``bld.bat``

You should look at the version 
in ``meta.yaml`` and rename the directory
appropriately (i.e. ``tweepy/`` becomes ``tweepy-2.3/``).
This is because build recipes might need to vary 
from version to version.

For packages that link against ``numpy`` I have found it
necessary to edit ``meta.yaml`` and pin the version explicitly::

    - numpy 1.8.2

then rename the directory to remind us that we pinned the version,
i.e. ``gensim/`` becomes ``gensim-0.10.1-np18/``.

Other packages (e.g. ``jdk`` and ``vim``) must have their
recipes hand-written.  This can be a difficult process and often requires
extensive knowledge of various compilers (e.g. ``gcc``, ``clang``, ``cl``),
their options and environment variables, and build
tools (e.g. ``cmake``, ``make``, ``nmake``, Visual Studio projects, etc).

We publish our recipes and encourage pull requests.  In particular we
want to encourage adding Windows and Mac support to our recipes.


Build and upload
----------------

*Make sure that you are in the root environment for this step*.

You can build ``tweepy-2.3/`` with the following command (from its parent directory)::

    conda build tweepy-2.3 

Assuming that all went well there will now be a tarball in ``~/miniconda/conda-bld/linux-64/``.

Since our organization on ``binstar`` is called ``ActivisionGameScience`` we were able
to upload the package with the following command:

    binstar upload -u ActivisionGameScience ~/miniconda/conda-bld/linux-64/tweepy-2.3-py27.tar.bz2


You can mimic this to upload your packages to your own personal account or organization.
Alternatively, you can ask us to pull and build your recipe.  Then we'll be happy to
upload your package to the ActivisionGameScience channel.


How to manage your codebase with conda
======================================

The real power of ``conda`` manifests itself when you want to manage your own code.
Most shops (especially C/C++ groups) have their own home-brewed build system that
is tightly coupled to the platform.  Even very experienced shops suffer from
Rube Goldberg machines that suck at least one FT developer to maintain them (Google Chrome,
``ninja`` is awesome, but ditch ``gyp`` please).

With ``conda`` we can escape this mess in a cross-platform manner.  You can
build code however you want, but use ``conda`` to handle the package and
dependency management.

We suggest building C/C++ projects with ``cmake``, and python projects with
``setuptools``.  Combined with ``conda`` this gives a fully cross-platform
solution that requires almost zero "special case" code.

Project 1: a wrapper around c-blosc
-----------------------------------

Look at the repo https://github.com/ActivisionGameScience/ags_example_cpp_lib.git.  This
is a dumb wrapper around the popular ``c-blosc`` compression library.  You could
clone that repo and build it by hand using ``cmake`` (the README contains instructions).

However, we have written a conda recipe to handle it.  Clone the recipes repo (that you are reading)::

    git clone https://github.com/ActivisionGameScience/ags_conda_recipes.git
    cd ags_conda_recipes

and build the package::

    conda build ags_example_cpp_lib-0.1.0

As always, when building and uploading new packages, make sure that you have
*deactivated* all environments (so you are in the root environment).

The package is now in ``~/miniconda/conda-bld/linux-64``.

However, we do *not* want to upload this to ``binstar``.  Recall that we
are thinking of this as a super-proprietary in-house library.  We want
to publish the package to our own private ``conda`` repository.


Behind-the-firewall conda repository
------------------------------------

We'll make the simplest private conda repository possible: a directory of tarballs.  
First create the following directory::

    mkdir /some/path/pkgs_inhouse

Then add it to your ``.condarc``::

    channels:
      - file:///some/path/pkgs_inhouse
      - https://conda.binstar.org/ActivisionGameScience
      - defaults

Next add a platform-specific subdirectory and copy your new package into it::

    mkdir /some/path/pkgs_inhouse/linux-64
    cp ~/miniconda/conda-bld/ags_example_cpp_lib-0.1.0.tar.bz2 /some/path/pkgs_inhouse/linux-64

Go into the directory and reindex it (this must be done whenever adding a new package)::

    cd /some/path/pkgs_inhouse/linux-64
    conda index

We are done.  We could install the package in the usual ``conda`` way::

    conda install ags_example_cpp_lib
