                ----- makesbkeys -----

To take full control of you computer's SecureBoot platform
you need to generate a custom set of keys and install them
in your computer's firmware.

This makefile automates the creation of the required signed
updates for your firmware. GNU make 3.81+ is required.

  $ make updates

The filenames can be customized with make variables CA, PK,
KEK and DB. The certificate subjects can be customized with
DNBASE, e.g.:

  $ make updates DNBASE="O=Acme Ltd./OU=SecureBoot"

OpenSSL settings like default validity period, key type or
whether keys shall be password-encrypted can be configured
in ./openssl.cnf.

Install the *.update files with KeyTool [0]. Much more
information on the topic of SecureBoot can be found on
Roderick W. Smith's pages [1].

Sign your kernels with PlatformKey.{key,crt}.

  - Anton Semjonov

---
[0]: https://github.com/mjg59/efitools
[1]: https://www.rodsbooks.com/efi-bootloaders/controlling-sb.html
