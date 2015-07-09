# fragments-user

*the documentation in this readme is work in progress and currently unfinished !*

*fragment-user is currently in alpha state and subject to breaking changes without notice.*

[![NPM Package](https://img.shields.io/npm/v/fragments-user.svg?style=flat)](https://www.npmjs.org/package/fragments-user)
[![Build Status](https://travis-ci.org/snd/fragments-user.svg?branch=master)](https://travis-ci.org/snd/fragments-user/branches)
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

make sure that at least the following environment variables are set
and set them to your own values:
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

add this migration to the migrations folder of your app:
https://github.com/snd/fragments-user/blob/master/migrations/20150327204310-add-user-table.sql

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



start the cockpit application:
```
./app serve cockpit
```
you can find the cockpit application in [src/factories/middleware.coffee](src/factories/middleware.coffee).
it only contains a user API.
if you need more than that - and you probably do - just copy the factory `cockpit` over to your application
and extend it.

*the `http` command used in the following is https://github.com/jkbrzt/httpie*

login to get an access **token** in the response:
```
http POST localhost:8080/api/cockpit/login username=casca password=opensesame
```

if you don't want the API to be at `/api/cockpit`
just overwrite factory `urlCockpitApi` in 
[src/factories/url.coffee](src/factories/url.coffee)
(or the other urls contained in that file)
in your own app.

see the currently logged in user:
```
http GET localhost:8080/api/cockpit/me 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```
(don’t forget to replace the **token** with the one you got in the response to the login request)

you should get a `forbidden` response as the user doesn't have the right to access the cockpit yet.

let’s give user the right to access cockpit:
```
./app rights:insert 1 canAccessCockpit
```
(don’t forget to replace the id with the one you got in the response to the user insert)

see the currently logged in user:
```
http GET localhost:8080/api/cockpit/me 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```
you should now get the user record in the response.

let's give the user the right to read users:
```
./app rights:insert 1 canReadUsers
```

insert some fake users:
```
./app fake:users 100
```

read all users:
```
http GET localhost:8080/api/cockpit/users 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

with limit and offset:
```
http GET 'localhost:8080/api/cockpit/users?limit=5&offset=20' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

ordered by username:
```
http GET 'localhost:8080/api/cockpit/users?order=name&asc=true' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

where email:
```
http GET 'localhost:8080/api/cockpit/users?where[email]=Evans_Jacobi@yahoo.com' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

where email contains:
```
http GET 'localhost:8080/api/cockpit/users?where[email][contains]=yahoo' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

where email ends:
```
http GET 'localhost:8080/api/cockpit/users?where[email][ends]=gmail.com' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

where name:
```
http GET 'localhost:8080/api/cockpit/users?where[name]=Rashawn.Haag' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

where name contains:
```
http GET 'localhost:8080/api/cockpit/users?where[name][contains]=nn' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

where name begins:
```
http GET 'localhost:8080/api/cockpit/users?where[name][begins]=an' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

id below:
```
http GET 'localhost:8080/api/cockpit/users?where[id][lt]=10' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

id between 10 and 20 (inclusive):
```
http GET 'localhost:8080/api/cockpit/users?where[id][gte]=10&where[id][lte]=20' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

created today:
```
http GET 'localhost:8080/api/cockpit/users?where[created_at]=today' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

where id:
```
http GET 'localhost:8080/api/cockpit/users/55' 'Authorization:Bearer eyJhbGciOiJIUzI1NiJ9.ZTdiMjJhZDk4OWY4Y2M5ZGQ1ZjcxM2Q3MDIxZjc2NTk.Tl-xvkKK9YP9Oz9o-BvuN2R3qi8VGwFpRzSh5cik-78'
```

...

<!--

### random copy ideas

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

-->

## [license: MIT](LICENSE)
