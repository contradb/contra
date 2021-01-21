# HOWTO install this repo's code on Amazon Web Services (AWS)

Because hosting ContraDB requires a lot of sub-programs, we use a
programs called _Packer_ and _Terraform_ to rent the stuff we need in
a reliable way.

This document details how to go about standing up your own contradb,
accessible to the world. If you think this is complicated _now_,
buddy, you shoulda seen it _before!_


## Prerequisites:

- AWS account
- some budget - these servers aren't free
- a bash-like shell such as is easily found on Linux or Mac to execute some commands
- optional: control of a free domain name, like `contradb.com`.



## Keypair

Setup a public/private keypair in `~/.ssh/contradb-terraform` and `~/.ssh/contradb-terraform.pub`.


## AWS Environment Variables

Choose a region:

```
export AWS_DEFAULT_REGION=us-east-2
```

Choose an account you have control over, and figure out how to set these variables' values correctly:

```
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=... (sometimes, depending on your account setup)
```


## Install packer

See Hashicorp's packer page for instructions. This guide was written against Packer 1.6.6.

## Build a packer image

If you're an offical-pants admin, then you may be able to skip this
step, since you should have access to our prebuilt amis. Note that if
there've been a lot of code changes since the last packer build, and
the code is relatively stable, it might save time to rebuild a new
packer ami anyway, since the asset compilation may be slowing down ec2
provisioning, but packer 'bakes in' the latest.

```
cd contra/terraform
packer build ./packer.json.pkr.hcl
```

This'll take 20 minutes or so, and spit out an ami id, like
`ami-0c417ea44719574e4`. Note this, you'll need it for terraform.



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
terraform plan -var=domain_name=example.com var=ami=ami-SavedFromTheStepAbove -out=the.tfplan
terraform apply the.tfplan
```
Obviously replace `example.com` with your domain. If you don't want a domain, omit the whole `-var=...` argument.
And replace `ami-SavedFromTheStepAbove` with the ami id from the packer step. 

You'll get a bunch of outputs from Terraform. You'll need them
later. You can read them out again with the command `terraform
output`.


## Test ssh

```
ssh -i ~/.ssh/contradb-terraform ubuntu@ec2-52-3-67-40.compute-1.amazonaws.com
```

Where the placeholder `ec2-52-3-67-40.compute-1.amazonaws.com` is
replaced with the `domain` output from terraform. Accept the
unfamiliar fingerprint and *welcome to your sever!* Type `exit` to
quit.


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

## DNS-only: Install ssl certificate

Ssh in again. Maybe this time you can use:

```
ssh ubuntu@contradb-example.com /home/ubuntu/contra/terraform/provisioning/certbot.sh your.email@mail.com
```

where:

- `contradb-example.com` gets replaced with your real domain
- `your.email@mail.com` gets replace with the email of the person letsencrypt sends emergency email to (I use my best email address)


## Test

Visit the site and make sure it works.


