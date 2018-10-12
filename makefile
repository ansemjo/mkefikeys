# Copyright (c) 2018 Anton Semjonov
# Licensed under the MIT License

# ------- variables --------

# certificate subject base
DNBASE := OU=Secureboot Keys

# target filenames
CA  := CertificateAuthority
PK  := PlatformKey
KEK := KeyExchangeKey
DB  := DatabaseKey

# openssl config
CONFIG  := ./openssl.cnf

# makeflags for any submakes
export MAKEFLAGS := --no-print-directory

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
certs : $(CA).crt $(PK).crt $(KEK).crt $(DB).crt

# generate all signed efivar updates
.PHONY : updates
updates : certs $(PK).update $(PK).remove $(KEK).update $(DB).update

# delete all files
.PHONY: clean
clean:
	@read -p "really delete everything? (type 'yes'): " sure && [[ $$sure == yes ]]
	git clean -fdx || rm -rf *.crt *.key *.update *.remove *.esl guid

# -------- actual targets --------

guid:
	uuidgen -r > $@

# create certificate authority
$(CA).crt $(CA).key :
	uuidgen -r | tr -d '-' > $(CA).srl
	openssl req -new -config $(CONFIG) -x509 -set_serial "0x$$(< $(CA).srl)" -extensions ext_ca \
		-keyout $(CA).key -out $(CA).crt -subj '/$(DNBASE)/CN=Certificate Authority/'

# create secureboot signing keys
%.crt %.key : $(CA).crt
	openssl req -new -config "$(CONFIG)" -subj '/$(DNBASE)/CN=$*/' -keyout "$*.key" |\
	openssl x509 -req -extfile $(CONFIG) -CA "$(CA).crt" -CAkey "$(CA).key" -out "$*.crt"

# create efi signature list from certificate
%.esl : %.crt guid
	cert-to-efi-sig-list -g "$$(< guid)" "$<" "$@"

# signer relationships
.SECONDARY: PK KEK db
PK KEK db:
efisig_$(PK)  := $(PK).key  $(PK).crt  PK
efisig_$(KEK) := $(PK).key  $(PK).crt  KEK
efisig_$(DB)  := $(KEK).key $(KEK).crt db

# create signed efivar update and removal
.SECONDEXPANSION:
%.update : $$(efisig_%) %.esl
	sign-efi-sig-list -g guid -k $(word 1,$^) -c $(word 2,$^) $(word 3,$^) $(word 4,$^) $*.update
%.remove : $$(efisig_%)
	sign-efi-sig-list -g guid -k $(word 1,$^) -c $(word 2,$^) $(word 3,$^) /dev/null $*.remove

