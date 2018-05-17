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

Well, you'll need some proficiency in Ruby. Check the Gemfile.lock for
the relevant versions. I use rvm to manage gems.

Database configuration is pretty simple and should be handled by
migrations. Creating a Postgres user is [handled in the wiki](https://github.com/contradb/contra/wiki/Setting-up-Postgres-for-Development-and-Testing).
After the database is created and migrated, there are two manual
things (which really should be in a script, even before tests, but I don't know how to do that):

1. run `rake db:seed` to create the special choreographer 'Unknown'
2. The first user you create through the website has super special
powers, so go ahead and create her. I like the username 'admonsterator'. 

## Deployment

[Deployment instructions](https://github.com/contradb/contra/wiki/Installing-new-git-version-onto-production-server) are in the wiki.

## Testing

    bin/rake spec

will run all tests. 
