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
If so, how many months and signatures will it take?
If you are starting a new project today, should it be subject to
the same environment that a 10-year-old project requires?

Point (3) is ugly if you need to deploy across many
environments.  Do you want to maintain separate builds for RHEL5, RHEL6,
Ubuntu12.04, and Ubuntu14.04?  Maintaining Windows and Mac builds is
already difficult enough.

Point (4) is a problem even for the Linux-only crowd.  Which distro?  

As far as system-level lock-in is concerned, ``pip`` is somewhat
better.  Thanks to ``virtualenv`` we're not installing packages
to our global ``site-packages`` anymore.  Too bad this only works well
for python code.


What is conda?
--------------

``conda`` keeps the good parts of these package managers
and jettisons the bad.  It handles native libraries (and python libraries),
but without being locked in at the system level.  No root access is necessary.  

Like ``virtualenv``, ``conda`` achieves this through "environments" (but
a more sophisticated version to handle native binaries as well).
You can have as many environments as you like (perhaps one per project).
They are lightweight and easy to deploy like ``docker``, but
fully cross-platform (Linux, Windows, and Mac).

In short, you can be productive on a spartan
RHEL5 box within minutes - no permission from IT is necessary.

``conda``'s package repository (analogous to ``pypi``) is called ``binstar``.  
Continuum, Inc., maintains many public packages on there.  ``binstar`` also 
allows you to upload your own public and private packages, and
group yourselves into *organizations* (similar to how github works).

For in-house packages (that cannot leave your firewall) you can maintain your
own package repository.  This can be as simple as a directory
containing tarballs (a "poor-man's ``binstar``").

These various possibilities can be mixed together because ``conda``
supports multiple simultaneous "channels".


What is Anaconda?
-----------------

``Anaconda`` is a specific set of packages being
maintained by Continuum, Inc. (http://www.continuum.io).  Most of
these packages are free, but some (like ``mkl``) require a license.
You can use ``Anaconda`` or not.  The price (a few hundred dollars per
year per developer) is well-worth the saved time in our experience.
We are not associated with Continuum.

The examples below build on top of ``Anaconda``, but you don't
need to buy a license if you don't want to.  After 30 days the ``mkl``,
``iopro``, and ``accelerate`` trials will simply expire and stop working.
If you don't need ``numpy`` then you won't miss it.


About this tutorial
-------------------

This tutorial describes how to use ``conda`` in a production environment (including
best practices and complicated codebases).
We believe there is no other document like this currently.

It covers how to install ``conda``, then how to create a dev environment
that is a mix of ``Anaconda`` and our own builds of popular software
(i.e. useful stuff missing from ``Anaconda``).  You are invited to use and
contribute to our environment, but otherwise you can gain inspiration.

Our list of packages is growing steadily.  The recipes that we wrote
are contained in this repo (that you are reading now).  Currently most recipes
only build in Linux, although we have added Windows support to some.  Mac
support is lagging.

Our environment should take about 5 minutes of typing and 30 minutes
of waiting (to download) before it is installed.  After this, 
we will pick a package at random and
demonstrate how we originally built it (from a recipe) and uploaded it to ``binstar``.

Finally, we describe 3 example projects that we have posted on github.  These
are full-fledged examples of how to use ``conda`` to manage your own "in-house"
packages and dependencies.

The first is a C++ library that builds using ``cmake``.  It 
depends on the third-party library ``c-blosc``.  The second is a C++ application that depends on
both.  We show how ``conda`` handles the dependency management.

The third is a python module that wraps the C++ library.  This gives you a nice pythonic interface
to the underlying C speed.  Again we manage the dependencies with ``conda``.


First steps: install conda
==========================

Before starting, find the most spartan machine possible.  Really annoy yourself.
I started with this barebones CentOS5 vagrant box:  
http://tag1consulting.com/files/centos-5.9-x86-64-minimal.box.

It has no ``git`` and no ``java`` (let alone ``javac``, ``maven``, and ``ant``).  
It doesn't even have ``vim``!  It's missing ``tmux`` and ``zsh``, 
and the system python is 2.4.  You can forget your favorite python libraries.

I hate this machine (note: I've been forced to work on a machine like this several times).

Let's turn this machine into a joy.  Download the ``Miniconda`` installer 
from http://conda.pydata.org/miniconda.html and run it::

    sh Miniconda-3.7.0-Linux_x86_64.sh

Install ``conda`` wherever you like (I chose ``~/miniconda``).
You can allow the installer to modify your ``.bashrc`` or not.  If so
then close and reopen your terminal.  
If not then you'll always be required to enable the "root" environment manually::

    export PATH=~/miniconda/bin:$PATH

Either way, typing ``where python`` should show ``~/miniconda/bin/python``.

Only conda-specific packages are allowed in the root environment.  Don't pollute
it with anything else.  Your real environments will live below ``~/miniconda/envs``.

If you want to use python 3 then I recommend having a separate ``conda``
instance for it.  You can download the ``Miniconda3`` installer
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

Check out the directory ``~/miniconda/envs/agsdev/``.  There's your new
environment.

You can "activate" it like this::

    source activate agsdev

Go ahead, test some things out!  You'll notice that everything is
there that I complained about (``git``, ``cmake``, ``vim``, ``tmux``, ``zsh``,
``java``, ``javac``, ``ant``, ``mvn``, and much more!).

You can deactivate the environment similarly (this puts you back into the root environment)::

    source deactivate

For future reference, if you build an environment that you like
then you can always export its specification like this (with
the environment activated)::

    conda list --export > myenv-linux-64.export


How we built and uploaded packages to binstar
=============================================

Now that you have our environment loaded and running, you
might want to know how we built it.

In order to build a package for ``conda`` you'll need to write
a "recipe".  Some recipes are so trivial that they can be
auto-generated by ``conda``.  Most libraries from
``pypi``, for example, can have their recipes auto-generated
like in this example::

    conda skeleton pypi tweepy

This creates a directory, ``tweepy/``, that contains
the following files::

    meta.yaml
    build.sh
    bld.bat

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

We are not so lucky with other packages (e.g. ``jdk`` and ``vim``).
Their recipes must be painstakingly written and often require 
extensive knowledge of various compilers (e.g. ``gcc``, ``clang``, ``cl``),
options, environment variables, and build
tools (e.g. ``cmake``, ``make``, ``nmake``, Visual Studio projects, etc).

We publish our recipes and encourage pull requests.  Our goal is to
work together and, in particular, add Windows and Mac support to our recipes.


Build and upload
----------------

*Make sure that you are in the root environment for this step*.  Do a ``source deactivate`` to
make sure.

You can build ``tweepy-2.3/`` with the following command (from its parent directory)::

    conda build tweepy-2.3 

Assuming that everything built correctly there will now be a tarball in ``~/miniconda/conda-bld/linux-64/``.

Since our organization on ``binstar`` is called ``ActivisionGameScience`` we uploaded
the package with the following command::

    binstar upload -u ActivisionGameScience ~/miniconda/conda-bld/linux-64/tweepy-2.3-py27.tar.bz2

Obviously I needed to input my personal account credentials, and my account was a member of our
organization (like github).


How to manage your codebase with conda
======================================

The real power of ``conda`` manifests itself when you want to manage your own code.
Most shops (especially C/C++ groups) have their own home-brewed systems that
are tightly coupled to the platform.  Even very experienced shops suffer from
Rube Goldberg machines (hi Google Chrome, ``ninja`` is awesome, but rethink ``gyp`` please).

With ``conda`` we can escape this mess in a cross-platform manner.  You can
build code however you want, but use ``conda`` to handle the package and
dependency management.

We suggest building C/C++ projects with ``cmake``, and python projects with
``setuptools``.  Combined with ``conda`` this gives a fully cross-platform
solution that requires almost zero "special case" code.

Project 1: a C++ wrapper around c-blosc
---------------------------------------

Look at the repo https://github.com/ActivisionGameScience/ags_example_cpp_lib.git.  This
is a dumb wrapper around the popular ``c-blosc`` compression library.  You could
clone that repo and build it by hand using ``cmake`` (the README contains instructions).

However, we have written a conda recipe to handle it.  Clone the recipes repo (that you are reading)::

    git clone https://github.com/ActivisionGameScience/ags_conda_recipes.git
    cd ags_conda_recipes

and build the package::

    conda build ags_example_cpp_lib-0.1.0

As always, when building packages, make sure that you have run ``source deactivate``
beforehand so that you are in the root environment.

The new package is now in ``~/miniconda/conda-bld/linux-64/``.

However, we do *not* want to upload this to ``binstar``.  Recall that we
are pretending that this is an in-house library.  We want
to publish the package to our own private ``conda`` repository.


Behind-the-firewall conda repository
------------------------------------

We'll make the simplest private conda repository possible: a directory of tarballs.  
First create some directory to hold your packages::

    mkdir /some/path/pkgs_inhouse

Then add it to your ``.condarc``::

    channels:
      - file:///some/path/pkgs_inhouse
      - https://conda.binstar.org/ActivisionGameScience
      - defaults

Next add a platform-specific subdirectory and copy your new package into it::

    mkdir /some/path/pkgs_inhouse/linux-64
    cp ~/miniconda/conda-bld/ags_example_cpp_lib-0.1.0.tar.bz2 /some/path/pkgs_inhouse/linux-64

Go into the directory and index it (this must be repeated whenever adding a new package)::

    cd /some/path/pkgs_inhouse/linux-64
    conda index

We are done.  We can install the package in the usual ``conda`` way::

    conda install ags_example_cpp_lib

and remove it just as easily::

    conda remove ags_example_cpp_lib


How it works
++++++++++++

To see how ``conda`` handled the package management, it is easiest to look at the README in the
repo for the project https://github.com/ActivisionGameScience/ags_example_cpp_lib.git.

There you will find details describing how to build and install the library manually
using ``cmake``.  The most important thing to notice is that ``cmake``
needs ``c-blosc`` to be already installed.
The location must be passed on the ``cmake`` command line using the
argument ``-DCBLOSC_ROOT=...``.

For completeness, you should also examine the ``cmake`` scripts::

    CMakeLists.txt
    cmake/Modules/FindCBLOSC.cmake

to see how the headers and binaries are *actually* found (this is what
the compiler wants).  ``cmake`` is the best tool for handling the build itself.

But how can we ensure that ``c-blosc`` will be installed?  For that matter,
how can we ensure that ``cmake`` will be installed?  

This is a dependency problem that is best left to ``conda``.
Look at the recipes repo (that you are reading now) in the directory
``ags_example_cpp_lib-0.1.0/``.  Reading ``meta.yaml`` you
will see that both ``cmake`` and ``c-blosc`` are listed as build
dependencies, and that ``c-blosc`` is repeated as a runtime dependency::

    requirements:
      build:
        - cmake
        - c-blosc

      run:
        - c-blosc

Fortunately, both ``cmake`` and ``c-blosc`` happen to be packages in
our binstar channel https://conda.binstar.org/ActivisionGameScience.  Hence
``conda`` will know how to install them before attempting a build
of ``ags_example_cpp_lib``.

We had to write recipes for ``c-blosc`` and ``cmake`` as well 
(otherwise how could we get the packages in our channel?).
Look, in their respective recipe directories ``c-blosc-1.5.2/`` and ``cmake-3.1.0/``,
at ``meta.yaml``.  You will see that ``c-blosc`` also
uses ``cmake`` to build, but requires no further dependencies.
``cmake`` requires no dependencies.  We were able to add them
as packages to our channel by first building and uploading ``cmake``,
then building and uploading ``c-blosc``.

Now look at the Linux build script ``build.sh`` in the recipe
directory ``ags_example_cpp_lib-0.1.0/``.
It contains the exact
``cmake`` commands that are described in its README::

    mkdir build
    cd build
    cmake ../ -DCBLOSC_ROOT=$PREFIX  -DCMAKE_INSTALL_PREFIX=$PREFIX

    make
    make install 

(``$PREFIX`` will be filled in by ``conda`` at build time).

So we see that ``cmake`` handles the build beautifully, and ``conda``
handles the dependency management with equal finesse.


Project 2: a C++ application using our library
----------------------------------------------

We do the same thing with the repo 
https://github.com/ActivisionGameScience/ags_example_cpp_app.git, except this
time without fewer comments.  This is a project that builds two executables:
``ags_blosc_compress`` and ``ags_blosc_decompress``.  They are command-line
utilities that perform blosc compression/decompresson.

This project links against the library project ``ags_example_cpp_lib`` that we
just built.  By transitivity it also links against the ``c-blosc`` binary.

As before, you could clone the repo and build it by hand using ``cmake`` (the README contains instructions).

However, we have written a conda recipe to handle it.  Clone the recipes repo (that you are reading)::

    git clone https://github.com/ActivisionGameScience/ags_conda_recipes.git
    cd ags_conda_recipes

and build the package::

    conda build ags_example_cpp_app-0.1.0

As always, when building packages, make sure that you have run ``source deactivate``
beforehand so that you are in the root environment.

The new package is now in ``~/miniconda/conda-bld/linux-64/``.  You can copy the
tarball to your behind-the-firewall conda repository as before (don't forget to run ``conda index``).

Like before, you should read both the ``conda`` recipe and the ``cmake`` scripts to
understand how this build and dependency management works.


Project 3: a python wrapper around our C++ library
--------------------------------------------------

We do the same thing with the repo 
https://github.com/ActivisionGameScience/ags_example_py_wrapper.git.
This is a project that installs a python module, ``ags_py_blosc_wrapper``,
that wraps the underlying C code in python.  Look at the README
in the project for details.

Since this is pure python (the binding is done via ``cffi``), no linking
is necessary.  There is no ``cmake`` code because there is no C/C++.  The
build is handled by the usual ``setuptools``.

However, we still need the ``ags_example_cpp_lib`` project to be installed
at runtime.  Again, ``conda`` handles this dependency.  Look at the recipe
``ags_example_py_wrapper_0.1.0/`` in this repo for details.

As before, you could clone the repo and build it by hand (the README contains instructions).

However, we have written a conda recipe to handle it.  Clone the recipes repo (that you are reading)::

    git clone https://github.com/ActivisionGameScience/ags_conda_recipes.git
    cd ags_conda_recipes

and build the package::

    conda build ags_example_py_wrapper-0.1.0

As always, when building packages, make sure that you have run ``source deactivate``
beforehand so that you are in the root environment.

The new package can be copied to your behind-the-firewall conda repository like the others.
