# efikeys

To take full control of you computer's SecureBoot platform you need to generate a custom set of keys
and install them in your computer's firmware. Information on SecureBoot in general can be found on
Roderick W. Smith's [pages][0] and various [wiki][1] [pages][2].

## create signing keys

This makefile automates the creation of the required certificates and signed updates for your
firmware. GNU make 3.81+ is required.

    mkefikeys updates

## configure

The filenames can be customized with make variables `PK`, `KEK` and `DB`. Certificate subjects can
be customized with `DNBASE`. RSA key bits, validity period and key encryption can be configured with
`BITS`, `DAYS` and `ENCRYPT`.

    mkefikeys updates DNBASE="O=Acme Ltd./OU=SecureBoot" ENCRYPT=yes

Install the `*.auth` files with [KeyTool][3] and use `sbsign` to sign your kernels with
`PlatformKey.{key,crt}`.

[0]: https://www.rodsbooks.com/efi-bootloaders/controlling-sb.html
[1]: https://wiki.archlinux.org/index.php/Secure_Boot
[2]: https://wiki.gentoo.org/wiki/Sakaki%27s_EFI_Install_Guide/Configuring_Secure_Boot
[3]: https://github.com/mjg59/efitools

# LICENSE

```
MIT License

Copyright (c) 2018 Anton Semjonov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
