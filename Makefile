# octaaf Makefile
#
# This program is free software; you can redistribute
# it and/or modify it under the terms of the GNU
# General Public License …

SHELL = /bin/sh

srcdir = .

NAME = octaaf
DESCRIPTION = A Go Telegram bot
VERSION = 0.1.0
ARCH = x86_64

all: compile

compile:
	docker build -t octaaf .
	docker run --rm \
		-v "$(shell pwd)":/go/src/octaaf \
		-w /go/src/octaaf octaaf:latest \
		/bin/ash -c "dep ensure && go build -v"
	strip octaaf

TMPDIR := $(shell mktemp -d)
TARGET := $(TMPDIR)/opt/octaaf
CONFIG := $(TARGET)/config
SYSTEM := $(TMPDIR)/usr/lib/systemd/system/

package:
	mkdir -p $(CONFIG)
	mkdir -p $(SYSTEM)

	cp ./octaaf $(TARGET)/
	cp ./octaaf.service $(SYSTEM)/octaaf.service
	cp ./config/.env.dist $(CONFIG)/.env
	cp ./config/database.yml.dist $(CONFIG)/database.yml
	cp -r ./migrations $(TARGET)/
	
	fpm -s dir -t rpm \
		--name "$(NAME)" \
		--description "$(DESCRIPTION)" \
		--version "$(VERSION)" \
		--architecture "$(ARCH)" \
		--iteration $(BUILD_NO) \
		--force \
		--config-files /usr/lib/systemd/system/octaaf.service \
		--config-files /opt/octaaf/config/.env \
		--config-files /opt/octaaf/config/database.yml \
		--chdir $(TMPDIR) \
		.; \
	
	rm -R $(TMPDIR)

clean:
	rm -f octaaf*.rpm

.PHONY: clean
