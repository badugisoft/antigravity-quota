VERSION ?= 1.4.1

.DEFAULT_GOAL := build
.PHONY: build bundle test screenshots package release-notes clean

test:
	swift test

screenshots:
	GENERATE_SCREENSHOTS=1 swift test

bundle:
	NO_INSTALL=1 APP_VERSION="$(VERSION)" ./scripts/build_app.sh

build:
	APP_VERSION="$(VERSION)" ./scripts/build_app.sh

package:
	./scripts/package_release.sh "$(VERSION)"

release-notes:
	./scripts/generate_release_notes.sh "$(VERSION)"

clean:
	rm -rf build
