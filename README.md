== README

=== ContraDB

This is an online database for managing contra dances. The intended
users are dance callers, dance choreographers, and opinionated
dancers. Users create, edit, update, and delete dances, as well as
copying and viewing other users' dances. Users can create programs of
dances and call them from their phone or print outs. 


=== COPYING

This library is released under the AGPL, see COPYING for details.

=== Development

Well, you'll need some proficiency in Ruby. Check the Gemfile.lock for
the relevant versions. I use rvm to manage gems.

Database configuration is pretty simple and should be handled by
migrations, but there are two manual things:

1) The first user you create has super special powers, so go ahead and
do that.  
2) You need to create a choreographer "unknown" first
thing. This is the choreographer that other dances get attributed to
when the system can't figure out a better choreographer to attribute
it to. Unknown can't easily be deleted, so get the spelling right.


=== Deployment

Deployment instructions are in the wiki at 
https://github.com/dcmorse/contra/wiki/Installing-new-git-version-onto-production-server

=== Testing

    bin/rake spec

will run all tests. 
