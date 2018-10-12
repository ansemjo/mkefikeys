# Copyright (c) 2018 Anton Semjonov
# Licensed under the MIT License

# certificate subject stem
DNBASE := OU=Secureboot Keys

# target filenames
CA  := CertificateAuthority
PK  := PlatformKey
KEK := KeyExchangeKey
DB  := DatabaseKey

# openssl config
CONFIG  := ./openssl.cnf

# generate all signing keys
all: $(CA).crt $(PK).crt $(KEK).crt $(DB).crt

# delete all files
.PHONY: clean
clean:
	@read -p "sure? [type 'yes'] " sure && [[ $$sure == yes ]]
	git clean -fdx

uuid.txt:
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
