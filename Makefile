# Copyright (C) 2020  The Symbiflow Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC
SHELL=bash

ALL_EXCLUDE = third_party .git env
FORMAT_EXCLUDE = $(foreach x,$(ALL_EXCLUDE),-and -not -path './$(x)/*')

PYTHON_SRCS=$(shell find . -name "*py" $(FORMAT_EXCLUDE))

IN_ENV = if [ -e env/bin/activate ]; then . env/bin/activate; fi;
env:
	python3 -mvenv --copies --clear env
	# Packaging tooling.
	$(IN_ENV) pip install -U pip twine build
	# Setup requirements.
	$(IN_ENV) pip install -r requirements.txt
	@$(IN_ENV) python -c "from fpga_interchange.version import version as v; print('Installed version:', v)"
	# Infra requirements.
	$(IN_ENV) pip install git+https://github.com/mithro/actions-includes.git

format: ${PYTHON_SRCS}
	$(IN_ENV) yapf -i ${PYTHON_SRCS}

test:
	$(IN_ENV) pytest -v

clean:
	rm -rf env

version:
	$(IN_ENV) python setup.py --version

.PHONY: clean env test-py version


build:
	$(IN_ENV) python -m build --sdist
	$(IN_ENV) python -m build --wheel

.PHONY: build

# PYPI_TEST = --repository-url https://test.pypi.org/legacy/
PYPI_TEST = --repository testpypi

upload-test:
	make clean
	make build
	$(IN_ENV) twine upload ${PYPI_TEST} dist/*

.PHONY: upload-test

upload:
	make clean
	make build
	$(IN_ENV) twine upload --verbose dist/*

.PHONY: upload

check:
	make clean
	make build
	$(IN_ENV) twine check dist/*.whl

.PHONY: check

install:
	$(IN_ENV) python setup.py install

.PHONY: install

TEST_LIKE_CI_RUN_SH := venv/actions/includes/actions/python/run-installed-tests/run.sh
$(TEST_LIKE_CI_RUN_SH):
	if [ ! -d venv/actions ]; then git clone https://github.com/SymbiFlow/actions venv/actions; fi
	cd venv/actions && git pull

# Format the GitHub workflow files
GHA_WORKFLOW_SRCS = $(wildcard .github/workflows-src/*.yml)
GHA_WORKFLOW_OUTS = $(addprefix .github/workflows/,$(notdir $(GHA_WORKFLOW_SRCS)))

.github/workflows/%.yml: .github/workflows-src/%.yml
	$(IN_ENV) python -m actions_includes $< $@

format-gha: $(GHA_WORKFLOW_OUTS)
	@echo $(GHA_WORKFLOW_OUTS)
	@true

.PHONY: format-gha
