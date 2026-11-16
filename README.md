# README

## ContraDB

This is the source code for [contradb.com](https://contradb.com), an
online database for managing contra dances. The intended users are
dance callers, dance choreographers, and opinionated dancers. Users
create, edit, update, and delete dances, as well as copying and
viewing other users' dances. Users can create programs of dances and
call them from their phone or print outs.

## COPYING

This library is released under the AGPL, see COPYING for details.

## Building your own personal production server

See [terraform/README.md](terraform/README.md) for details on
installing contradb in the cloud with Terraform and Amazon Web
Services.

## Development

### Once configuration is complete

In terminal one:

```
bin/rails s
```

And optionally in terminal two:

```
bin/webpack-dev-server
```

But how do I get configured? Contact us for help. Getting contradb
running locally is a 397-step process that is not easy unless you
have a good understanding of ruby, javascript, postgres, and your
operating-system of choice. But if you don't wanna contact us, here's
some notes on how to do it, current at time of writing, but probably
outdated by the time you read this.

### Install rbenv to manage versions of ruby https://github.com/rbenv/rbenv

After rbenv I also had to install a plugin: `git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build`.

### `cd contra`

### get the proper version from `.ruby-version` and install it

```
rbenv install $(cat .ruby-version)
```

I had to also do `sudo apt install gcc g++ make` to get a C compiler and the `make` build tool. Apt is a package manager similar to brew.

### `gem install bundler`

### `bundle install`

Then I errored out for lack of postgres, so I did a detour:

### Install Postgres

```
sudo apt install libpq-dev
```
then choose

#### Option 1: local

For my OS I followed https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-20-04 , basically:

```
sudo apt install postgresql postgresql-contrib
```


#### Option 2: containerized

I use Rancher Desktop and claude wrote me this command:

```
docker run -d --name contra-postgres -p 127.0.0.1:5432:5432 -e POSTGRES_USER=$USER -e POSTGRES_PASSWORD='balance+swing' -e POSTGRES_DB=contradev -v contra_postgres_data:/var/lib/postgresql/data postgres:12
```

I chose postgres 12 because that's what's in prod at time of writing, and I wanted to match for image compatibility. 

After that, you have to tell Rails where to find the db. Put 
```
export CONTRADB_DATABASE_HOST=localhost
```
in your .bashrc or `<root>/.envrc` if you're a fancy direnv user like me. Also if you're fancy: `direnv allow`. Well actually I had to also add this to .envrc:
```
if [[ -n ${NODE_VERSIONS:-} ]]; then
  use node
fi
```
And in  `~/.config/direnv/direnvrc`:
```
export NODE_VERSIONS="$HOME/.nvm/versions/node"
export NODE_VERSION_PREFIX="v"
```
This is a janky setup depending on both nvm and direnv. Probably better to just put it in your .bashrc!

### JS setup

I had to go install node and yarn to get this to work. I already had `nvm` installed, so 
```
nvm install 14.15.3
nvm use # references .nvmrc version
npm install -g yarn@1.22.22
yarn install --check-files
```

### Run `bin/rails server`

### Configure Postgres

Database configuration is pretty simple and should be handled by
migrations. Creating a Postgres user is [handled in the wiki](https://github.com/contradb/contra/wiki/Postgres-for-contradb-dev).
If you've come this far, maybe it's time to contact the project for a db replica so you can test against real data, but if you want to create your own empty DB:

1. run `rake db:seed` to create the special choreographer 'Unknown' and the 'verified' tag.
2. The first user you create through the website has super special
   powers.

### Configure rspec

I needed to install chromedriver, which was a binary I downloaded and plopped in /usr/local/bin.

Then in a secret undocumented step that nobody tells you about, you have to also install google-chrome, supposedly at the same version (86 here).

I also did `rake db:seed test`, but that screwed things up by creating Chorographer 'unknown'. I had to go in and destroy them manually.

## Development

### JS

#### libfigure

Libfigure is the js code that understands contra figures. It runs both on the client side for React, and on the server side for server-side rendering. Because the js environment on the server side (maybe especially in the testing environments) the js is written in an archaic dialect of es5.

To change things correctly edit the code that lives in `app/javascript`. Then run `bin/rake libfigure:compile` to copy the code into asset pipeline.

## Deployment

[Deployment instructions](https://github.com/contradb/contra/wiki/Installing-new-git-version-onto-production-server) are in the wiki.

## Testing

```
bin/rspec
```

will run lots of ruby tests.

```
yarn test
```

will run a few js tests.

```
yarn eslint app/javascript/dance-table.tsx
```

will run the js linter on `app/javascript/dance-table.tsx`. This is currently the only file that is even remotely lintable.

```
bin/webpack-dev-server
```

This will indirectly run the typescript compiler in watch mode - for some reason ts compile errors don't stop the ruby, so I keep an eye on this terminal.
