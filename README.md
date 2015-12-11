# miniCA – an easy to use mini CA

This project contains all you need to run a simple CA. 

`miniCA` was started in the context of the pipe2me and kinko projects:

- pipe2me: a TCP socket proxy [https://github.com/kinkome/pipe2me](https://github.com/kinkome/pipe2me)
- kinko: easy to use privacy starts at your home [https://kinko.me](https://kinko.me)

As such, miniCA might reference to these projects in some cases. However, 
the code itself is generic enough to be of use to anyone who wants to manage
certificates in a no-nonsense fashion.

## miniCA features

miniCA differs from the few open source scripts for running CAs with this
feature set:

- based upon openssl
- covered by automatic tests 
- implements a three-layer certificate hierarchy: there is a long-living 
  root certificate, a set of intermediates, with only one current certificate,
  and the leaf ("end-user") certificates.

miniCA is licensed under the terms of the MIT license; see LICENSE.MIT for details.

## Installing miniCA

To install the miniCA package just download the current version from
github. No further installation is needed. 

To run tests you might need additional software, see "Testing miniCA" below.

## Testing miniCA

To run tests you must have the following software installed and accessible
via your $PATH: `ruby`, `nginx`, `curl`, `gnutls-cli`, `make`. These should 
be installable via your system's package manager.

Other software needed to run tests comes in the `./test/res` directory and
needs no additional installation.

Some tests try to run a https server on localhost. For this to work you must
make sure that all domain names ending in .dev resolve to 127.0.0.1. In general 
you can achieve this using `dnsmasq`.

To run tests just execute `make` in either the main directory or in the `./test`
subdirectory.

## Using miniCA

### Initializing miniCA: `miniCA init -r DIR`

To initialize miniCA run miniCA init -r DIR, where `DIR` points to 
a directory to hold the CA files. This initializes a root CA in `$DIR/root`,
and an intermediate.

This also creates the root certificate in `$DIR/root.pem`.
 
Note: You can skip explicite initialization of miniCA; all commands that 
need a CA will initialize it when needed.

### Generate a key pair: `miniCA generate`

The `miniCA generate` command allows to generate a private/pubkey pair, and
a signing request. This creates a .priv, a .pem, and a .csr file:

- `.priv`: the private key.
- `.pem`: the public key.
- `.csr`: the Certificate Signing Request. Pass this on to your CA, or 
  sign it via `miniCA sign` (see below.)

**Note:** This command is typically run on the machine, which needs the 
certificate. It also does not need a CA installation, and is included in 
the miniCA package for convinience reasons only.

    # example: generate key pair and signing request for the common name
    # pinkunicorn.pipe2.me
    miniCA generate pinkunicorn.pipe2.me

    # this creates the following files:
    pinkunicorn.pipe2.me.priv
    pinkunicorn.pipe2.me.pem
    pinkunicorn.pipe2.me.csr

**Note:** This command generates passwordless key file, however -p option
will force it to ask for passphrese for key file protection.
    
    # example:
    miniCA generate -p pserver
    

### Configuring a miniCA installation: `miniCA init`

`miniCA` is able to work with multiple CA instances. Each CA instance lives in
its own directory. To create a miniCA instance in a specific place, run
`miniCA init -r <directory>`.

This creates a number of files in the given directory, most notably:

- ca/crl/crl.pem: an empty Certificate Revocation List 
- ca/root/certificate.pem: the root certificate; can be used to verify certificates
- ca/root/private_key.pem: the root key. Keep this secret.

### Create a certificate: `miniCA sign filename.csr`

A certificate certifies a specific identity on a key. For this you need 
a CSR (certificate signing request). This is typically generated with the 
`miniCA generate` command. 

The `miniCA sign` command signs the CSR passed into it:

    miniCA sign -r demoCA pinkunicorn.pipe2.me.csr

This creates the certificate in pinkunicorn.pipe2.me.pem.

**Note:** The `-r` option defines the root directory of the CA; in this example `demoCA`.

### Managing intermediate certificates

Certificates signed by miniCA are not signed directly with the root 
certificate, but with *intermediates*. The idea is that if an intermediate
is compromised, one only must revoke the intermediate certificate, while 
the root certificate remains intact. Also the root certificate is intended
to live very long, while intermediates have a much shorter livespan (~ 1 year).

miniCA manages a **current intermediate**, which will be used to create leaf 
certificates. If you sign a CSR (using `miniCA sign`, see above), you sign,
in fact, against the current intermediate. Also signing creates not only a .pem 
file (which still is the most relevant result), but also the following:

- `.bare.pem`: while the .pem file contains the full certificate chain, the 
  .bare.pem file contains only the signed leaf certificate. 
- `.reverse.pem`: the .reverse.pem file contains the full certificate chain, 
  but in reverse order. This is to work around an issue with openssl certificate
  validation, see https://github.com/kinkome/miniCA/issues/2.

You can generate and activate a new intermediate by running 

    miniCA intermediate:new

**Note:** This is not yet implemented. See [https://github.com/kinkome/miniCA/issues/4](https://github.com/kinkome/miniCA/issues/4) for progress.
