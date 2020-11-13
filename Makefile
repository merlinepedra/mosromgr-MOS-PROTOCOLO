# vim: set noet sw=4 ts=4 fileencoding=utf-8:

# Project-specific constants
DOC_HTML=docs/build/html
DOC_TREES=docs/build/doctrees
DOC_S3=s3://apps.test.newslabs.co.documentroot/docs/mosromgr/

# Default target
all:
	@echo "make install - Install on local system"
	@echo "make develop - Install symlinks for development"
	@echo "make test - Run tests"
	@echo "make doc-graphs - Generate graphviz graphs"
	@echo "make doc - Build the docs as HTML"
	@echo "make doc-serve - Serve the docs locally"
	@echo "make doc-deploy - Deploy the docs to S3"

install:
	pip install .

develop:
	pip install -e .[test,doc]
	@echo "To build the docs you will also need to install graphviz using apt/brew"

lint:
	pylint -E mosromgr

test: lint
	coverage run --rcfile coverage.cfg -m pytest -v tests
	coverage report --rcfile coverage.cfg

doc-graphs:
	python docs/images/class_hierarchy.py
	dot -Tpng docs/images/class_hierarchy.dot -o docs/images/class_hierarchy.png
	dot -Tsvg docs/images/class_hierarchy.dot -o docs/images/class_hierarchy.svg

doc: doc-graphs
	sphinx-build -b html -d $(DOC_TREES) docs/ $(DOC_HTML)

doc-serve:
	cd $(DOC_HTML) && python -m http.server

doc-deploy:
	aws s3 rm $(DOC_S3)* --recursive
	aws s3 cp $(DOC_HTML) $(DOC_S3) --recursive
