.DEFAULT_GOAL := build

build:
	@set -e;	\
	for file in `ls ./scripts/[0-99]*.sh`;	\
	do					\
		bash $${file};			\
	done					\

clean:
	sudo rm -rf $(CURDIR)/tempdir;

distclean: clean
	docker rmi unifi-protect-arm64-builder:latest -f; \
	docker rmi unifi-protect-arm64:latest -f; \
	rm -rf $(CURDIR)/downloads
