# Copyright (c) 2018 Anton Semjonov
# Licensed under the MIT License

CA  := CertificateAuthority
PK  := PlatformKey
KEK := KeyExchangeKey
DB  := DatabaseKey

CONFIG  := ./openssl.cnf
UUIDGEN := uuidgen --random

uuid.txt:
	$(UUIDGEN) > $@

$(CA).srl:
	$(UUIDGEN) | tr -d '-' > $(CA).srl

.PHONY: CA
CA : $(CA).crt
$(CA).crt : $(CA).srl
	openssl req -new -config $(CONFIG) -x509 \
		-keyout $(CA).key -out $(CA).crt \
		-set_serial "0x$$(< $(CA).srl)" \
		-extensions ext_ca

.PHONY: PK
PK : $(PK).crt
$(PK).crt : $(CA).crt
	openssl req -new -config $(CONFIG) \
		-keyout $(PK).key |\
	openssl x509 -req -extfile $(CONFIG) \
		-CA $(CA).crt -CAkey $(CA).key \
		-out $(PK).crt
