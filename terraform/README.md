# Rent hosting on Amazon Web Services (AWS)

Because hosting ContraDB requires a lot of sub-programs, we use a
program called _Terraform_ to rent the stuff we need in a reliable way.

This document details how to go about standing up your own contradb,
accessible to the world. If you think this is complicated _now_,
buddy, you shoulda seen it _before!_ :D


## Prerequisites:

- AWS account
- some budget - these servers aren't free
- a linux/mac-like system to execute the commands below (or the
  wherewithall to translate them to your OS)


## Keypair

Setup a public/private keypair in `~/.ssh/contradb-terraform` and `~/.ssh/contradb-terraform.pub`.


## AWS Environment Variables

Choose a region:

```
export AWS_DEFAULT_REGION=us-east-1
```

Choose an account you have control over, and figure out how to set these variables' values correctly:

```
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=... (sometimes, depending on your account setup)
```


## Decide if you want a domain name.

If you do want a domain name, you may have to buy one or use
one. Later you'll need to configure your registrar, see 'Finish DNS'
below.

If you don't want a domain name, you'll access the program by raw ip
address or aws' patented even-harder-than-ip-addresses-to-remember
domain names.


## Install Terraform

These instructions were written with version 0.14.3.


## Terraform it up

```
cd contra/terraform
terraform init
terraform plan -var=domain_name=example.com -out=the.tfplan
terraform apply the.tfplan
```
Obviously replace `example.com` with your domain. If you don't want a domain, omit the whole `-var=...` argument.

You'll get a bunch of outputs from Terraform. You'll want to save them
somewhere for as long as the installation is live (though if you lose
them they're also recoverable from the AWS web console).


## Test ssh

```
ssh -i ~/.ssh/contradb-terraform ubuntu@[123.45.67.89]
```

Where `[123.45.67.89]` is your instance's ip address. Accept the
changed fingerprint and *welcome to your sever!* Type `exit` to quit.


## Finish DNS

Go to your registrar and add the nameservers that Terraform told you about after the apply.


### Note to offical-pants admins:

The domain `contradb.com` is hosted by namecheap.com. Here is a handy link
to the [namecheap dashboard](https://ap.www.namecheap.com/dashboard).

## TODO

This guide doesn't actually install ContraDB yet, it just rents the infrastructure.
Future expansion will install rails, postgres, and a https certificate.
