# An easy to use CA

This directory contains everything related to running a private CA, in the 
context of the pipe2me (and kinko) applications. The package is used to 
generate, sign, and revoke certificates.

The implemented CA is based on openssl.
 
This package is aimed at an easy to use package; consequently many (open)ssl 
options are not available at all, or only with a configuration file. 

## Configuring the ca package

## Generate a certificate: `ca generate`

The `ca generate` command allows to generate a private/pubkey pair, and
a signing request. This creates a .priv and a .csr file.

    # example: generate key pair and signing request for the common name
    # pinkunicorn.pipe2.me
    ca generate pinkunicorn.pipe2.me

    # this creates the following files:
    pinkunicorn.pipe2.me.priv
    pinkunicorn.pipe2.me.csr

## Create a certificate: `ca sign filename.csr`

The `ca sign` command signs the CSR passed into it:

    ca sign -r demoCA pinkunicorn.pipe2.me.csr

This creates the certificate in pinkunicorn.pipe2.me.pem.

**Note:** The `-r` option defines the root directory of the CA; in this example `demoCA`.
