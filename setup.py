#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (C) 2020  The SymbiFlow Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC


import setuptools


# Generate the version number
def get_version():
    def clean_scheme(version):
        from setuptools_scm.version import get_local_node_and_date
        return get_local_node_and_date(version) if version.dirty else ''

    return {
        'write_to': 'fpga_interchange/version.py',
        'version_scheme': 'post-release',
        'local_scheme': clean_scheme,
    }


# Read in the module description from the README.md file.
with open("README.md", "r") as fh:
    long_description = fh.read()


# Read in the setup_requires from the requirements.txt file.
setup_requires = []
with open('requirements.txt') as fh:
    for r in fh:
        if '#' in r:
            r = r[:r.find('#')]
        r = r.strip()
        if not r:
            continue
        if r not in ('-e .',):
            setup_requires.append(r)


setuptools.setup(
    # Package human readable information
    name="fpga-interchange",
    use_scm_version=get_version(),
    author="SymbiFlow Authors",
    author_email="symbiflow@lists.librecores.org",
    description="Python library for reading and writing FPGA interchange files",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/SymbiFlow/python-fpga-interchange",
    license="ISC",
    license_files=["LICENSE"],
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: ISC License",
        "Operating System :: OS Independent",
    ],
    # Package contents control
    packages=setuptools.find_packages(),
    include_package_data=True,
    # Requirements
    python_requires=">=3.7",
    install_requires=[
        "pycapnp",
        "python-sat",
        "pyyaml",
        # TODO: https://github.com/SymbiFlow/python-fpga-interchange/issues/11
        "git+https://github.com/litghost/rapidyaml.git@fixup_python_packaging#egg=rapidyaml&subdirectory=api/python",
    ],
)
