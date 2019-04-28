# README

## ContraDB

This is an online database for managing contra dances. The intended
users are dance callers, dance choreographers, and opinionated
dancers. Users create, edit, update, and delete dances, as well as
copying and viewing other users' dances. Users can create programs of
dances and call them from their phone or print outs. 

## COPYING

This library is released under the AGPL, see COPYING for details.

## Development

Contact us for help. But if you don't wanna, here's some information:
Check the Gemfile.lock for the relevant versions of Ruby. I use rbenv
to manage gems.

Database configuration is pretty simple and should be handled by
migrations. Creating a Postgres user is [handled in the wiki](https://github.com/contradb/contra/wiki/Setting-up-Postgres-for-Development-and-Testing).
If you've come this far, maybe it's time to contact the project for a db replica so you can test against real data, but if you want to create your own empty DB:

1. run `rake db:seed` to create the special choreographer 'Unknown'
2. The first user you create through the website has super special
powers.

### Outline of install for Windows - Dec 2018

Sketch only and not tested - ask for help on any of this

- Virtualbox Ubuntu LTS
- clone git repo
- install rbenv
- install ruby 2.4.1 in rbenv
- gem install bundler
- bundle install
- configure config/database.yml
- get a replica database from contradb.com

Then:
- bin/rspec [runs all tests]
- bin/rails s [runs server on http://localhost:3000]
- bin/rails c [runs repl loop]

## Deployment

[Deployment instructions](https://github.com/contradb/contra/wiki/Installing-new-git-version-onto-production-server) are in the wiki.

## Testing

```
bin/rspec
```
will run all tests. 
