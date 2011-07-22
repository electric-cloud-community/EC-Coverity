# Makefile

SRCTOP=..
include $(SRCTOP)/build/vars.mak
build: package
unittest:

systemtest: start-selenium test-setup test-run stop-selenium

emmatest:
	$(MAKE) NTESTFILES="systemtest/emma.ntest" RUNEMMATESTS=1 test-setup test-run

NTESTFILES ?= systemtest

test-setup:
	$(EC_PERL) ../EC-Coverity/systemtest/setup.pl $(TEST_SERVER) $(PLUGINS_ARTIFACTS)

test-run: systemtest-run

include $(SRCTOP)/build/rules.mak
