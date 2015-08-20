# fragments-user

*the documentation in this readme is work in progress and currently unfinished !*

*fragment-user is currently in alpha state and subject to breaking changes without notice.*

[![ALPHA](http://img.shields.io/badge/Stability-ALPHA-orange.svg?style=flat)]()
[![NPM Package](https://img.shields.io/npm/v/fragments-user.svg?style=flat)](https://www.npmjs.org/package/fragments-user)
[![Build Status](https://travis-ci.org/snd/fragments-user.svg?branch=master)](https://travis-ci.org/snd/fragments-user/branches)
[![coverage-86%](http://img.shields.io/badge/coverage-86%-brightgreen.svg?style=flat)](https://rawgit.com/snd/fragments-user/master/coverage/lcov-report/index.html)
[![Dependencies](https://david-dm.org/snd/fragments-user.svg)](https://david-dm.org/snd/fragments-user)

**have a token-auth protected API running within minutes with [fragments](https://github.com/snd/fragments)**

[fragments](https://github.com/snd/fragments)
is an up and coming Node.js library
that structures web applications with (request time) dependency injection.

fragments-user is a collection of factories for fragments
that provide small to large building blocks
for the rapid and fun development of maintainable, testable and elegant
postgres-backed rest APIs
with token-based-auth (JWT)
and rights management.
it comes preloaded with authentication and user management API endpoints.

fragments-user also serves as an example-application for fragments.  
the tests for that example-application serve as additional integration tests for fragments.

### install

```
npm install fragments-user
```

in your fragments [`app`](app) file make sure you are using
[fragments-postgres](https://github.com/snd/fragments-postgres)
and fragments-user:

``` js
#!/usr/bin/env node

var hinoki = require('hinoki');
var fragments = require('fragments');
var fragmentsPostgres = require('fragments-postgres');
var app = hinoki.source(__dirname + '/src/factories');

var source = hinoki.source([
  app,
  fragmentsPostgres,
  fragments.source,
  fragments.umgebung,
]);

source = hinoki.decorateSourceToAlsoLookupWithPrefix(source, 'fragments_');

module.exports = fragments(source);

if (require.main === module) {
  module.exports.runCommand();
}
```

### configuration environment variables

make sure that the following environment variables are set
to your own values:
``` bash
export PORT=8080
export BASE_URL="http://localhost:$PORT"

export MIGRATION_PATH="migrations"

export POSTGRES_DATABASE='my_database'
export DATABASE_URL="postgres://localhost:5432/$POSTGRES_DATABASE"
export POSTGRES_POOL_SIZE=40

export JWT_ENCRYPTION_PASSWORD='replace this with your super secret jwt encryption password'
export JWT_SIGNING_SECRET='replace this with your super secret jwt signing secret'
```

### [commands](src/factories/command.coffee)

call `./app` to see a list of all available commands.

fragments-user itself adds the following commands:
```
rights {user-id} - list the rights of user with `user-id`
rights:delete {user-id} {right} - revoke `right` from user with `id`
rights:insert {user-id} {right} - grant `right` to user with `id`
users [optional-user-id] - show all users or just the user with `optional-user-id` (if given)
users:delete {user-id} - delete user with `user-id`
users:insert {name} {email} {password} - insert user
fake:users {count} - insert `count` fake users
```

add
[migrations/20150327204310-users.sql](migrations/20150327204310-users.sql)
to the migrations folder of your app.

reset your database if necessary:
```
./app pg:drop-create
```

migrate:
```
./app pg:migrate
```

insert a user:
```
./app users:insert casca casca@example.com opensesame
```

confirm that the user is inserted by listing all users:
```
./app users
```

start the server:
```
./app serve
```
you can find the `server` callback/middleware in [src/factories/server.coffee](src/factories/server.coffee).
it only contains a user API.
if you need more than that - and you probably do - just copy the [`server`](src/factories/server.coffee) factory over to your application
and extend it.

### customization

fragments-user provides sensible defaults.
customizing them is dead-simple.

you can overwrite every part which vastly changes the behaviour

### user API documentation

*the `http` command used in the following is https://github.com/jkbrzt/httpie*

the code and test for each API action are linked.
refer to them for additional documentation (especially for edge cases).
use the code as inspiration to build your own API actions.
most actions are only a few lines of code.

#### [signup !](src/factories/api-signup-post.coffee) ([tests](src/factories/test/api-signup-post.coffee))

signup 
```
http POST localhost:8080/api/signup username=casca email=casca@example.com password=opensesame
```

if you don't want users to be able to sign up just omit
`apiSignupPost` from your middleware.

#### [login !](src/factories/api-login-post.coffee) ([tests](src/factories/test/api-login-post.coffee))

login to get an access **token** in the response:
```
http POST localhost:8080/api/login username=casca password=opensesame
```

if you don't want the API to be at `/api`
just add the factory `urlApi` in your own app
which overwrites `urlApi` in
[src/factories/url.coffee](src/factories/url.coffee).
overwrite other fragments as needed.

#### [get current user](src/factories/api-current-user-get.coffee) ([tests](src/factories/test/api-current-user-get.coffee))

see the user that is logged in with a specific **token**:
```
http GET localhost:8080/api/me 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```
(don’t forget to replace the **token** with the one you got in the response to the login request)

you should get a `forbidden` response as the user doesn't have the right to access the cockpit yet.

let’s give user the right to access cockpit:
```
./app rights:insert 1 canAccessCockpit
```
(don’t forget to replace the id with the one you got in the response to the user insert)

see the user logged in with a specific **token**:
```
http GET localhost:8080/api/me 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```
you should now get the user record in the response.

#### [update current user !](src/factories/api-current-user-patch.coffee) ([tests](src/factories/test/api-current-user-patch.coffee))

```
http PATCH localhost:8080/api/me name=griffith 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

#### [filter all users](src/factories/api-users-get.coffee) ([tests](src/factories/test/api-users-get.coffee))

to read all users the logged in user needs the right `canReadUsers`.  
let's grant that right:
```
./app rights:insert 1 canReadUsers
```

insert some fake users so we have some records to filter:
```
./app fake:users 100
```

all users:

```
http GET localhost:8080/api/users 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

with limit and offset:
```
http GET 'localhost:8080/api/users?limit=5&offset=20' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

ordered by username:
```
http GET 'localhost:8080/api/users?order=name&asc=true' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

where email:
```
http GET 'localhost:8080/api/users?where[email]=Evans_Jacobi@yahoo.com' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

where email contains:
```
http GET 'localhost:8080/api/users?where[email][contains]=yahoo' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

where email ends:
```
http GET 'localhost:8080/api/users?where[email][ends]=gmail.com' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

where name:
```
http GET 'localhost:8080/api/users?where[name]=Rashawn.Haag' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

where name contains:
```
http GET 'localhost:8080/api/users?where[name][contains]=nn' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

where name begins:
```
http GET 'localhost:8080/api/users?where[name][begins]=an' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

id below:
```
http GET 'localhost:8080/api/users?where[id][lt]=10' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

id between 10 and 20 (inclusive):
```
http GET 'localhost:8080/api/users?where[id][gte]=10&where[id][lte]=20' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

created today:
```
http GET 'localhost:8080/api/users?where[created_at]=today' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

... you get the idea. if something feels like it should work but doesn't: [file an issue !](https://github.com/snd/fragments-user/issues/new)

#### [create user !](src/factories/api-users-post.coffee) ([tests](src/factories/test/api-users-post.coffee))

to create users the logged in user needs the right `canCreateUsers`.  
let's grant that right:
```
./app rights:insert 1 canCreateUsers
```

now let's create a user:
```
http POST 'localhost:8080/api/users name=ubik email=ubik@example.com password=opensesame rights='' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

#### [get user where id](src/factories/api-user-get.coffee) ([tests](src/factories/test/api-user-get.coffee))

```
http GET 'localhost:8080/api/users/55' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

#### [update user !](src/factories/api-user-patch.coffee) ([tests](src/factories/test/api-user-patch.coffee))

to update users the logged in user needs the right `canUpdateUsers`.  
let's grant that right:
```
./app rights:insert 1 canUpdateUsers
```

now let's update a user:
```
http PATCH 'localhost:8080/api/users/1 name=ubik email=ubik@example.com password=opensesame rights='' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

#### [delete user !](src/factories/api-user-delete.coffee) ([tests](src/factories/test/api-user-delete.coffee))

to delete users the logged in user needs the right `canDeleteUsers`.  
let's grant that right:
```
./app rights:insert 1 canDeleteUsers
```

now let's delete a user:
```
http DELETE 'localhost:8080/api/users/3 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

### access control

just overwrite them

some properties of the currently implemented rights management.

a user can't update his own rights.
it's not even allowed.

a user with the right to create users can potentially create
a user that has more rights.

a user with the right to updates users can change his and other users rights.

the rights `canCreateUsers` and `canUpdateUsers` can be escalated into all rights.
they are to be considered superuser rights.

<!--

simple but powerful and flexible rights management

you can hook into anything

restful http API with helpful error messages

takes care of ... so you can ...

gets all the user stuff out of the way
so you can focus on the meat of your application

it is a fragments bundle that you can use in your fragments application.
it is also a self contained application server that serves an API.

- its both demo application and library
such that it stays in active development.

- also an additional suite of integration tests for fragments
  - and all the rest of your stack
- also documentation for fragments

- token based auth (JWT)
- simple rights management
- middleware for restful API endpoints
  - login
  - get currently logged in user
  - update currently logged in user
  - admin user management
    - table list
    - insert user (`POST /api/users/`)
    - delete user (`DELETE /api/users/:id`)
    - update user (`PATCH /api/users/:id`)
- use whatever you need
- ready to go / easy: sensible defaults for everything
- well tested
- command line commands
  - add users
  - give them rights

- simple: everything can be overwritten and customized
  easily replace every part of the system

build from very small and simple parts.
replace and reuse ...

also some backoffice tools

sensible defaults. dead-simple customization.

-->

## [license: MIT](LICENSE)
