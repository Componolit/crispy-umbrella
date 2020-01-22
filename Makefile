VERBOSE ?= @
export MYPYPATH = $(PWD)/stubs

python-packages := bin rflx tests stubs

build-dir := build
noprefix-dir := build/noprefix

project := test
test-bin := $(build-dir)/test
test-files := $(wildcard generated/rflx-*.ad? tests/*.ad? tests/*.raw test.gpr)

ifneq ($(NOPREFIX),)
project := $(noprefix-dir)/test
test-bin := $(noprefix-dir)/$(build-dir)/test
test-files := $(addprefix $(noprefix-dir)/, $(subst /rflx-,/,$(test-files)))
endif

.PHONY: check format test test_python test_spark prove_spark clean

check:
	black --check $(python-packages)
	isort -rc -c $(python-packages)
	flake8 $(python-packages)
	pylint $(python-packages)
	mypy $(python-packages)

format:
	black $(python-packages)
	isort -rc $(python-packages)

test: check test_python test_spark prove_spark

test_python:
	coverage run --branch --source=rflx -m unittest -b

test_spark: $(test-files)
	gprbuild -P$(project)
	$(test-bin)

test_spark_optimized: $(test-files)
	gprbuild -P$(project) -Xoptimization=yes
	$(test-bin)

prove_spark: $(test-files)
	gnatprove -P$(project) $(GNATPROVE_ARGS)

clean:
	gprclean -Ptest
	gnatprove -Ptest --clean
	test -d $(noprefix-dir) && rm -r $(noprefix-dir) || true
	rmdir $(build-dir)

remove-prefix = $(VERBOSE) \
	mkdir -p $(dir $@) && \
	sed 's/RFLX.//g' $< > $@.tmp && \
	mv $@.tmp $@

$(noprefix-dir)/generated/%: generated/rflx-%
	$(remove-prefix)

$(noprefix-dir)/tests/%: tests/rflx-%
	$(remove-prefix)

$(noprefix-dir)/%: %
	$(remove-prefix)
