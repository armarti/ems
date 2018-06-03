#!/usr/bin/env python
"""
 +-----------------------------------------------------------------------------+
 |  Extended Memory Semantics (EMS)                            Version 1.4.1   |
 |  Synthetic Semantics       http://www.synsem.com/       mogill@synsem.com   |
 +-----------------------------------------------------------------------------+
 |  Copyright (c) 2016, Jace A Mogill.  All rights reserved.                   |
 |                                                                             |
 | Redistribution and use in source and binary forms, with or without          |
 | modification, are permitted provided that the following conditions are met: |
 |    * Redistributions of source code must retain the above copyright         |
 |      notice, this list of conditions and the following disclaimer.          |
 |    * Redistributions in binary form must reproduce the above copyright      |
 |      notice, this list of conditions and the following disclaimer in the    |
 |      documentation and/or other materials provided with the distribution.   |
 |    * Neither the name of the Synthetic Semantics nor the names of its       |
 |      contributors may be used to endorse or promote products derived        |
 |      from this software without specific prior written permission.          |
 |                                                                             |
 |    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS      |
 |    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT        |
 |    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR    |
 |    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL SYNTHETIC         |
 |    SEMANTICS LLC BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,   |
 |    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,      |
 |    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR       |
 |    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   |
 |    LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     |
 |    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       |
 |    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.             |
 |                                                                             |
 +-----------------------------------------------------------------------------+
"""
from setuptools import setup, Extension
import sys
import os
import platform
from glob import glob

PACKAGE_NAME = "libems"
PACKAGE_VERSION = "1.4.1" + ".1"
REPO_ROOT_DIR = os.path.realpath(os.path.dirname(__file__))
THIS_DIR = REPO_ROOT_DIR
SRC_DIR = os.path.join(THIS_DIR, 'src')
INCLUDE_DIR = os.path.join(THIS_DIR, 'include')
MODULE_DIR = os.path.join(THIS_DIR, 'Python')

# OS Specific link flags
link_args = []
if sys.platform in ("linux", "linux2"):
    link_args.append("-lrt")
elif sys.platform in ("darwin",):
    os.environ['MACOSX_DEPLOYMENT_TARGET'] = '.'.join(platform.mac_ver()[0].split('.')[:2])
    link_args.append("-stdlib=libc++")
else:
    pass

setup(
    name=PACKAGE_NAME,
    version=PACKAGE_VERSION,
    packages=[PACKAGE_NAME],
    package_dir={PACKAGE_NAME: os.path.relpath(MODULE_DIR, THIS_DIR)},
    setup_requires=["cffi>=1.0.0", "setuptools"],
    install_requires=["cffi>=1.0.0"],

    # Author details
    author='Jace A Mogill',
    author_email='mogill@synsem.com',

    description='Extended Memory Semantics (EMS) for Python',
    license='BSD',

    # The project's main homepage.
    url='https://github.com/SyntheticSemantics/ems',

    data_files=[
        ('include/{}'.format(PACKAGE_NAME), glob(os.path.join(THIS_DIR, 'include/ems/ems*.h'))),
    ],

    ext_modules=[
        Extension(
            "{pkg}/{pkg}".format(pkg=PACKAGE_NAME),
            sources=[os.path.relpath(os.path.join(SRC_DIR, src), THIS_DIR) for src in os.listdir(SRC_DIR)],
            extra_link_args=link_args,
            include_dirs=[os.path.relpath(INCLUDE_DIR, THIS_DIR)],
            define_macros=[
                # ('BUILD_PYTHON', None),
            ],
        ),
    ],
    long_description='Persistent Shared Memory and Parallel Programming Model',
    keywords=" ".join([
        "nonvolatile memory",
        "NVM",
        "NVMe",
        "multithreading",
        "multithreaded",
        "parallel",
        "parallelism",
        "concurrency",
        "shared-memory",
        "multicore",
        "manycore",
        "transactional-memory",
        "TM",
        "persistent-memory",
        "pmem",
        "Extended-Memory-Semantics",
        "EMS",
    ]),
    classifiers=[  # https://pypi.org/classifiers/
        "License :: OSI Approved :: BSD License",
        "Programming Language :: C",
        "Programming Language :: C++",
        "Programming Language :: Python :: 2",
        "Programming Language :: Python :: 3",
        "Programming Language :: JavaScript",
    ],
)
