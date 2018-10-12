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

# generate all signing keys and certificates
.PHONY : certs
certs : $(CA).crt $(PK).crt $(KEK).crt $(DB).crt

# generate all signed efivar updates
.PHONY : updates
updates :
	make $(PK).auth        SIGNER=$(PK)  VAR=PK
	make Remove$(PK).auth  SIGNER=$(PK)  VAR=PK
	make $(KEK).auth       SIGNER=$(PK)  VAR=KEK
	make $(DB).auth        SIGNER=$(KEK) VAR=db

# delete all files
.PHONY: clean
clean:
	@read -p "are you sure? [type 'yes'] " sure && [[ $$sure == yes ]]
	git clean -fdx

# -------- actual targets --------

uuid:
	uuidgen -r > $@

# create certificate authority
$(CA).crt :
	uuidgen -r | tr -d '-' > $(CA).srl
	openssl req -new -config $(CONFIG) -x509 -set_serial "0x$$(< $(CA).srl)" -extensions ext_ca \
		-keyout $(CA).key -out $(CA).crt -subj '/$(DNBASE)/CN=Certificate Authority/'

# create secureboot signing keys
%.crt : $(CA).crt
	openssl req -new -config "$(CONFIG)" -subj '/$(DNBASE)/CN=$*/' -keyout "$*.key" |\
	openssl x509 -req -extfile $(CONFIG) -CA "$(CA).crt" -CAkey "$(CA).key" -out "$*.crt"

# create efi signature list from certificate
%.esl : %.crt uuid
	cert-to-efi-sig-list -g "$$(< uuid)" "$<" "$@"

# empty efi signature list
Remove%.esl :
	printf '' > $@

# create signed efivar update, needs SIGNER and VAR
%.auth : %.esl
	sign-efi-sig-list -g uuid -k $(SIGNER).key -c $(SIGNER).crt $(VAR) $< $@
