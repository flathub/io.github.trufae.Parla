REPO_DIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

DOCKER_CMD := docker
BUILDER_TOOLS_URL := https://github.com/flatpak/flatpak-builder-tools.git
BUILDER_TOOLS_COMMIT := 737c0085912f9f7dabf9341d4608e2a77a51a73a

install:
	flatpak run org.flatpak.Builder \
		--force-clean \
		--sandbox \
		--user \
		--install \
		--install-deps-from=flathub \
		--ccache \
		--mirror-screenshots-url=https://dl.flathub.org/media/ \
		--repo=repo \
		builddir \
		io.github.trufae.Parla.yaml

update: update-deltachat
	flatpak-external-data-checker --edit-only io.github.trufae.Parla.yaml

update-deltachat: DELTACHAT_TAG:=$(shell gh release view --repo "chatmail/core" --json tagName --template '{{.tagName}}')
update-deltachat: DELTACHAT_COMMIT:=$(shell gh api /repos/chatmail/core/git/ref/tags/${DELTACHAT_TAG} --jq '.object.sha')
update-deltachat:
	yq -i '.modules[0].sources[0].tag="$(DELTACHAT_TAG)" | .modules[0].sources[0].commit = "$(DELTACHAT_COMMIT)"' io.github.trufae.Parla.yaml
	$(DOCKER_CMD) run --rm \
		--volume=$(REPO_DIR)/cargo-sources-deltachat.json:/cargo-sources-deltachat.json:rw \
		docker.io/library/python:3.12.4 \
		bash -c '\
			mkdir -p deltachat tools && \
			(cd deltachat && \
				echo Checking out deltachat... && \
				git init -q && \
				git remote add origin "https://github.com/chatmail/core.git" && \
				git fetch --depth 1 origin "$(DELTACHAT_TAG)" && \
				git checkout -q FETCH_HEAD) && \
			(cd tools && \
				echo Checking out builder tools... && \
				git init -q && \
				git remote add origin "$(BUILDER_TOOLS_URL)" && \
				git fetch --depth 1 origin "$(BUILDER_TOOLS_COMMIT)" && \
				git checkout -q FETCH_HEAD) && \
			\
			echo Installing dependencies... && \
			pip install tomlkit aiohttp && \
			echo Regenerating sources... && \
			python3 /tools/cargo/flatpak-cargo-generator.py /deltachat/Cargo.lock -o /cargo-sources-deltachat.json'

clean:
	rm -rf .flatpak-builder builddir repo

.PHONY: install clean update update-deltachat
