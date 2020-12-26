# Rent hosting on Amazon Web Services (AWS)

Because hosting ContraDB requires a lot of sub-programs, we use a
program called _Terraform_ to rent the stuff we need in a reliable way.

This document details how to go about standing up your own contradb,
accessible to the world. If you think this is complicated _now_,
buddy, you shoulda seen it _before!_ :D


## Prerequisites:

- AWS account
- some budget - these servers aren't free
- a bash-like shell such as is easily found on Linux or Mac to execute some commands


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

If you do want a domain name, you may need to buy one. Later you'll need some extra steps marked "DNS-only"

If you don't want a domain name, you'll access the program by raw ip
address or aws' patented even-harder-than-ip-addresses-to-remember
domain names.


## DNS-only: Configure TTL for testing

In [dns.tf](dns.tf) there's a ttl. Set it something short like 60 seconds while you're getting domains set up the first time.


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


## DNS-only: Finish DNS

Go to your registrar and add the nameservers that Terraform told you about after the apply.


I'd test it with

```
nslookup contradb-example.com
```

If that doesn't work, then consider

```
nslookup contradb-example.com aws-ns1.amazon.com
```

Where `aws-ns1.amazon.com` is the first of the nameservers you got
back from the terraform output. If that _still_ doesn't work,
something's wrong with this terraform code, because we hired
`aws-ns1.amazon.com` to say the IP address of our server, darn it! If
it did work, then maybe your local dns just hasn't refreshed it's
cache yet. Wait 20 minutes and try again.

Lastly, restore the TTL in [dns.tf](dns.tf) so it doesn't bust its own cache
every 60 seconds. How about 3600?


### Note to offical-pants admins:

The domain `contradb.com` is hosted by namecheap.com. Here is a handy link
to the [namecheap dashboard](https://ap.www.namecheap.com/dashboard).

## TODO

This guide doesn't actually install ContraDB yet, it just rents the infrastructure.
Future expansion will install rails, postgres, and a https certificate.
