#!/usr/bin/make -f

# Copyright (c) 2018 Anton Semjonov
# Licensed under the MIT License
#
# Partially based on work by Roderik W. Smith:
#  https://www.rodsbooks.com/efi-bootloaders/controlling-sb.html

# ------- variables --------

# command shell
SHELL := /usr/bin/bash

# certificate subject base
DNBASE := OU=Secureboot Keys

# openssl config
CONFIG  := ./openssl.cnf

# target filenames
PK  := PlatformKey
KEK := KeyExchangeKey
DB  := DatabaseKey

# signature relationships
signer-$(PK)  := $(PK).key  $(PK).crt
signer-$(KEK) := $(PK).key  $(PK).crt
signer-$(DB)  := $(KEK).key $(KEK).crt

# efi variable names
efivar-$(PK)  := PK
efivar-$(KEK) := KEK
efivar-$(DB)  := db

# -------- pseudo-targets --------

# show usage information
.PHONY : help
define HELP
usage help:
	make certs    - generate all signing certificates with openssl
	make updates  - create all signed efi variable updates
	make clean    - remove all files
endef
help :
	@: $(info $(HELP))

# generate all signing keys and certificates
.PHONY : certs
certs : $(PK).crt $(KEK).crt $(DB).crt

# generate all signed efivar updates
.PHONY : updates
updates : certs $(PK).auth $(KEK).auth $(DB).auth

# delete all files
.PHONY: clean
clean:
	@read -p "really delete everything? (type 'yes'): " sure && [[ $$sure == yes ]]
	git clean -fdx || rm -rf $$(< .gitignore)

# never automatically remove these precious files
.PRECIOUS: %.key %.crt %.auth

# -------- actual targets --------

# random guid for efi signature lists
guid: ;	uuidgen -r > $@

# random inline serial for openssl certs
serial := <(uuidgen -r | tr -d '-')

# create platform signing key
$(PK).crt $(PK).key :
	openssl req -x509 -new -config $(CONFIG) -extensions ext_ca	-keyout $(PK).key -out $(PK).crt -subj '/$(DNBASE)/CN=$(PK)/'

# create keyexchange and database signing keys
.SECONDEXPANSION:
%.crt %.key : $$(signer-%)
	openssl req -new -config $(CONFIG) -subj '/$(DNBASE)/CN=$*/' -keyout $*.key |\
	  openssl x509 -req -extfile $(CONFIG) -CAkey $(word 1,$^) -CA $(word 2,$^) -CAserial $(serial) -out $*.crt

# create efi signature list from certificate
%.esl : %.crt guid
	cert-to-efi-sig-list -g $$(< guid) $< $@

# create signed efivar update and removal
.SECONDEXPANSION:
%.auth : %.esl $$(signer-%)
	sign-efi-sig-list -g guid -k $(word 2,$^) -c $(word 3,$^) $(efivar-$*) $< $@

