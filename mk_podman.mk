exec := podman run -ti --rm -v .:/workdir -w /workdir docker.io/library/node:20

.PHONY: podman_bundle
podman_bundle:
	$(exec) $(MAKE) bundle
