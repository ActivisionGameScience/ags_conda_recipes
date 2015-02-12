Motivation
==========

If you are developing in C, C++, or python then you should 
use ``conda`` (https://github.com/conda/conda.git) for your
package (dependency) management.  For other languages you might consider it
as well.

To justify this, consider other package managers:

* python has ``pip`` + ``virtualenv``

* C/C++ has ``apt-get``, ``yum``, ``nuget``, ``homebrew``, etc

``pip`` works well if you are only dealing with pure python packages.  However,
many of the best python packages (e.g. ``numpy``) are written in C, and
``pip`` is not a good tool for managing native binaries.

System-level package managers like ``apt-get`` and ``yum`` work
much better with native binaries, but they have serious drawbacks of their own: 

1) need admin privileges to install packages (and changes are system-wide)

2) limited to what is available (and allowed!) on the platform

3) your builds will be tightly coupled to the platform 

4) every platform has its own package manager

5) how do you manage dependencies within your own codebase?

Point (2) is particularly nasty.  How many of us have been told that our deploy
environment is RHEL6 with python 2.6 and gcc 4.4 (or, worse, RHEL5)?  
Your favorite libraries will not be available.

Point (3) is ugly if you need to deploy across many
environments.  Maintaining Windows and Mac builds is hard enough.  
Do you want to maintain separate builds for RHEL5, RHEL6,
Ubuntu12.04, and Ubuntu14.04 as well?

Point (4) is a problem even for the Linux-only crowd.  Which distro?  

Point (1) is now solved for Linux developers who
use ``docker`` (Windows and Mac platforms can run the same 
code in a lightweight VM using ``boot2docker``).  Unfortunately there
is not a similar solution for *native* Windows and Mac projects.

The python world solved (1) with the introduction of ``virtualenv``.
Unfortunately this only works well for pure python code.


What is conda?
--------------

``conda`` keeps the good parts of these package managers
and jettisons the bad.  Like ``virtualenv``, ``conda`` avoids the 
system-level lock-in through "environments".  Unlike ``virtualenv``, it can handle
native packages as well.  

You can have as many environments as you like (e.g. one
per project).  Root access is not required, and there is no reliance on
platform-specific containers (like ``docker``) or VMs.  ``conda``
handles packages *natively* for Windows, Linux, and Mac.

``conda``'s package repository (analogous to ``pypi``) is called ``binstar``.  
``binstar`` allows you to upload your own public and private packages, and
group yourselves into *organizations* (similar to how github works).

For proprietary packages (that cannot leave your firewall) you can maintain your
own package repository.  This can be as simple as a directory
containing tarballs (a "poor-man's ``binstar``").

These various possibilities can be mixed together because ``conda``
supports multiple "package channels".


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

This tutorial is an end-to-end example showing how to use ``conda`` in production.
We use it to manage both public packages and proprietary packages (kept behind our firewall).

We will use our own dev environment as an example.  Our dev environment
is a mix of ``Anaconda`` and our own builds of popular software.  Packages
not in ``Anaconda`` are available on our public channel https://binstar.org/ActivisionGameScience.  
You are invited to contribute to our environment, but otherwise you can use
it as an example.

Our packages are built using recipes that are contained in this repo (the repo
you are reading now).  Currently most recipes
only support Linux, although we have added Windows support to some.  Mac
support is lagging.

It should take about 5 minutes to get going (followed by a 30-minute
nap while the packages download).

Next, we will pick a package at random
and describe how it was built (using a "recipe") and uploaded to ``binstar``.

Finally, we will describe 3 example projects that we posted on github.  You
should pretend that these are proprietary projects.  You will learn how to
build them and publish the packages behind your firewall.

Besides learning how to publish packages behind your firewall, you will
see that ``conda`` handles in-house dependencies in the same way that
it handles third-party dependencies.

As a bonus, we will demonsrate how to use ``cmake`` to build C++ projects,
and how to use ``cffi`` to create python wrappers around 
C/C++ libraries.


First steps: install conda
==========================

Before starting, find the most spartan machine possible.  Really annoy yourself.
I started with this barebones CentOS5 vagrant box:  
http://tag1consulting.com/files/centos-5.9-x86-64-minimal.box.

It has no ``git`` and no ``java`` (let alone ``javac``, ``mvn``, or ``ant``).  
It doesn't even have ``vim``!  It's missing ``tmux`` and ``zsh``, 
and the system python is 2.4.  You can forget your favorite python libraries.
It doesn't have ``autotools`` (good luck building anything).

Let's turn this machine into a joy.  Download the ``Miniconda`` installer 
from http://conda.pydata.org/miniconda.html and run it::

    sh Miniconda-3.7.0-Linux_x86_64.sh

Install ``conda`` wherever you like (I chose ``~/miniconda``).
You can allow the installer to modify your ``.bashrc`` or not.  If so
then close and reopen your terminal.  
If not then you'll always have to enable ``conda`` manually::

    export PATH=~/miniconda/bin:$PATH

Either way, typing ``where python`` should show ``~/miniconda/bin/python``.
This is your "root" environment.

Only conda-specific packages are allowed in the root environment.  Don't pollute
it with anything else.  Your real environments will live below ``~/miniconda/envs``.

    Pro tip: if you want to use python 3 then I recommend having a separate ``conda``
    instance for it.  You can download the ``Miniconda3`` installer
    and set up a separate root environment in ``/some/other/path/miniconda3``.

Now edit your ``~/.condarc`` file and add both our ActivisionGameScience channel and the default
channels::

    channels:
      - https://conda.binstar.org/ActivisionGameScience
      - defaults

Remember that indents are 2 spaces in YAML (``conda`` will complain otherwise).  Since
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

After your walk, check out the directory ``~/miniconda/envs/agsdev/``.  There's your new
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


How did we build and upload our packages to binstar?
====================================================

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

You should look at the library version 
in ``meta.yaml`` and rename the directory
appropriately (i.e. ``tweepy/`` becomes ``tweepy-2.3/``).
This is because build recipes might need to vary 
from version to version.

    Pro tip: for packages that link against ``numpy`` I have found it
    necessary to edit ``meta.yaml`` and pin the ``numpy`` version explicitly::
    
        - numpy 1.8.2
    
    then rename the directory to remind us that we pinned the version,
    i.e. ``gensim/`` becomes ``gensim-0.10.1-np18/``.

We are not so lucky with other packages (e.g. ``jdk`` and ``vim``).
Their recipes must be painstakingly written and often require 
extensive knowledge of various compilers (e.g. ``gcc``, ``clang``, ``cl``),
options, environment variables, and build
tools (e.g. ``cmake``, ``make``, ``nmake``, Visual Studio projects, etc).

Because of these difficulties, it is important for us to publish our
recipes and encourage pull requests.  Our goal is to
work together to build a comprehensive library of third-party packages.
We especially encourage adding Windows and Mac support.


Build and upload
----------------

*Make sure that you are in the root environment for this step*.  Do a ``source deactivate`` to
make sure.

You can build ``tweepy-2.3/`` with the following command (from its parent directory)::

    conda build tweepy-2.3 

Assuming that everything built correctly there will now be a tarball in ``~/miniconda/conda-bld/linux-64/``.

    Pro tip: for packages that compile C/C++ code (including ``cython``), you should always build 
    with the oldest compiler possible (at least for gcc).  I use a RHEL5 box to
    build our packages because more modern versions of ``libc`` will be able to use those binaries
    (but not the other way around).

    Unfortunately, MSVC binaries are not always forward ABI compatible, so the same advice may
    not apply there

Since our organization on ``binstar`` is called ``ActivisionGameScience`` I uploaded
the package with the following command::

    binstar upload -u ActivisionGameScience ~/miniconda/conda-bld/linux-64/tweepy-2.3-py27.tar.bz2

Obviously I needed to input my personal credentials (and be a member of the ActivisionGameScience
organization).


How to manage your codebase with conda
======================================

The real power of ``conda`` manifests itself when you want to manage your own code.
Most shops (especially C/C++ groups) suffer from their own home-brewed Rube Goldberg
machines.

With ``conda`` we can escape this mess in a cross-platform manner.  You can
build code however you want, but use ``conda`` to handle the package and
dependency management.

    Pro tip: although you can build using ``autotools`` or whatever,
    we strongly suggest building C/C++ projects with ``cmake``, and python projects with
    ``setuptools``.  Combined with ``conda`` this gives a fully cross-platform
    solution that requires very little platform-specific code.


Project 1: a C++ wrapper library around c-blosc
-----------------------------------------------

Look at the repo https://github.com/ActivisionGameScience/ags_example_cpp_lib.git.  This
is a dumb C++ wrapper around the popular ``c-blosc`` compression library.  You could
clone that repo and build it by hand using ``cmake`` (the README contains instructions).

However, we have written a conda recipe to handle it.  Clone this repo (that you are reading)::

    git clone https://github.com/ActivisionGameScience/ags_conda_recipes.git
    cd ags_conda_recipes

and build the recipe::

    conda build ags_example_cpp_lib-0.1.0

As always, when building packages, make sure that you have run ``source deactivate``
beforehand so that you are in the root environment.

The new package is now in ``~/miniconda/conda-bld/linux-64/``.

However, we do *not* want to upload this to ``binstar``.  Recall that we
are pretending that this is a proprietary library.  We want
to publish the package to our own repository behind the firewall.


Behind-the-firewall conda repository
------------------------------------

We'll make the simplest conda repository possible: a directory of tarballs.  
First create some directory to hold your packages::

    mkdir /some/path/pkgs_inhouse

Then add it to your ``.condarc``::

    channels:
      - file:///some/path/pkgs_inhouse
      - https://conda.binstar.org/ActivisionGameScience
      - defaults

Next add a platform subdirectory and copy your new package into it::

    mkdir /some/path/pkgs_inhouse/linux-64
    cp ~/miniconda/conda-bld/ags_example_cpp_lib-0.1.0.tar.bz2 /some/path/pkgs_inhouse/linux-64

Go into the platform subdirectory and index it (this must be repeated whenever adding a new package)::

    cd /some/path/pkgs_inhouse/linux-64
    conda index

We are done.  We can install the package in the usual ``conda`` way::

    conda install ags_example_cpp_lib

and remove it just as easily::

    conda remove ags_example_cpp_lib


How it works
++++++++++++

To see how ``conda`` handled the package management, it is easiest to start with the README in the
repo https://github.com/ActivisionGameScience/ags_example_cpp_lib.git.

There you will find details describing how to build and install the library manually
using ``cmake``.  The most important thing to notice is that ``cmake``
needs ``c-blosc`` to be already installed.
The location must be passed on the ``cmake`` command line using the
argument ``-DCBLOSC_ROOT=...``.

For completeness, you should have a look at the ``cmake`` scripts::

    CMakeLists.txt
    cmake/Modules/FindCBLOSC.cmake

to see how the headers and binaries are *actually* found (this is what
the compiler wants).  ``cmake`` is the best tool for handling the build itself.

But how can we ensure that ``c-blosc`` will be installed?  For that matter,
how can we ensure that ``cmake`` will be installed?  

This is a dependency problem that is best left to ``conda``.
Look at this repo (that you are reading now) in the directory
``ags_example_cpp_lib-0.1.0/``.  In ``meta.yaml`` you
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

    Aside: we wrote recipes for ``c-blosc`` and ``cmake`` as well.
    Look in their respective recipe directories ``c-blosc-1.5.2/`` and ``cmake-3.1.0/``
    at ``meta.yaml``.  You will see that ``c-blosc`` also
    uses ``cmake`` to build (a wise choice), but requires no further dependencies.
    ``cmake`` requires no dependencies.  We were able to add these packages
    to our channel by first building and uploading ``cmake``,
    then building and uploading ``c-blosc``.

Back in the recipe for ``ags_example_cpp_lib-0.1.0/``, 
look at the Linux/Mac build script ``build.sh``.
It contains the exact
``cmake`` commands that are described in the README::

    mkdir build
    cd build
    cmake ../ -DCBLOSC_ROOT=$PREFIX  -DCMAKE_INSTALL_PREFIX=$PREFIX

    make
    make install 

(``$PREFIX`` will be filled in by ``conda`` at build time).

So we see that ``cmake`` handles the build beautifully, and ``conda``
ensures that the necessary dependencies will be there when ``cmake``
goes looking for them.


Project 2: a C++ application using our library
----------------------------------------------

We can repeat this game with the repo
https://github.com/ActivisionGameScience/ags_example_cpp_app.git.
This project builds two executables:
``ags_blosc_compress`` and ``ags_blosc_decompress``.  They are command-line
utilities that perform blosc compression/decompresson.

This project compiles against the library that we just built (``ags_example_cpp_lib``).

    Aside:  by transitivity it also links against ``c-blosc`` (but does not compile against it).
    We could've side-stepped this transitivity complication by having ``cmake`` build our
    library as a MODULE.  Modules are self-contained:  they have their
    dependencies linked in already.  To keep the example simple, however, I restrained myself to only
    STATIC and SHARED versions of the library.

As before, if you wanted then you could clone the repo and build it by hand using ``cmake`` (the README contains instructions).

Again, we have written a conda recipe to handle it.  Assuming that you already cloned this repo (that you are reading)::

    git clone https://github.com/ActivisionGameScience/ags_conda_recipes.git
    cd ags_conda_recipes

you can build the package::

    conda build ags_example_cpp_app-0.1.0

(remember to run ``source deactivate`` beforehand so that you are in the root environment).

The new package is now in ``~/miniconda/conda-bld/linux-64/``.  Like before, you can put it
in your behind-the-firewall conda repository::

    cp ~/miniconda/conda-bld/ags_example_cpp_app-0.1.0.tar.bz2 /some/path/pkgs_inhouse/linux-64
    cd /some/path/pkgs_inhouse/linux-64
    conda index

I highly recommend that you read both the ``conda`` recipe and the ``cmake`` scripts to
understand how this build and dependency management worked.


Project 3: a python wrapper around our C++ library
--------------------------------------------------

We do the same thing with the repo 
https://github.com/ActivisionGameScience/ags_example_py_wrapper.git.
This project installs a python module, ``ags_py_blosc_wrapper``,
that wraps our C++ library.  Look at the README for details how to
use it.

Since this is pure python (the binding is done via ``cffi``), no linking
is necessary.  There is no ``cmake`` because there is no C/C++ to build.  The
build is handled by ``setuptools``.

However, we need our C++ library to be available at runtime.
Again, ``conda`` handles this dependency.  Here is the relevant
section in ``ags_example_py_wrapper_0.1.0/meta.yaml``::

    requirements:
      build:
        - python
        - setuptools
    
      run:
        - python
        - numpy 1.8.2
        - cffi
        - ags_example_cpp_lib

Assuming you've already cloned this repo (that you are reading)::

    git clone https://github.com/ActivisionGameScience/ags_conda_recipes.git
    cd ags_conda_recipes

you can build the package in seconds::

    conda build ags_example_py_wrapper-0.1.0

The new tarball, located in ``~/miniconda/conda-bld/linux-64/``, can be added to your 
behind-the-firewall conda repository like the others::

    cp ~/miniconda/conda-bld/ags_example_py_wrapper-0.1.0.tar.bz2 /some/path/pkgs_inhouse/linux-64
    cd /some/path/pkgs_inhouse/linux-64
    conda index

and installed the ``conda`` way::

    conda install ags_example_py_wrapper
    ipython
        In[0]: from ags_py_blosc_wrapper import BloscWrapper
        In[1]: b = BloscWrapper() 

        ...

See the README for usage instructions.


License
=======

All files are licensed under the BSD 3-Clause License as follows:
 
| Copyright (c) 2015, Activision Publishing, Inc.  
| All rights reserved.
| 
| Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
| 
| 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
|  
| 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
|  
| 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
|  
| THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

