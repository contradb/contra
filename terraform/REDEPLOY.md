# Redeploy

Sometimes you don't want to stand up a server just for a tiny code update.
It would be nice to have the existing AWS ec2 do a `git pull` and update itself.
For that, there is this document.

1. `ssh` into the server as detailed in the [Terraform README](./README.md)
2. Run the script in the `contra/sysadmin/cloud/deploy-aws` directory
3. Hope it works and fix it if it doesn't!
