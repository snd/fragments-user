# fragments-user

*the documentation in this readme is work in progress and currently unfinished !*

[![NPM Package](https://img.shields.io/npm/v/fragments-user.svg?style=flat)](https://www.npmjs.org/package/fragments-user)
[![Build Status](https://travis-ci.org/snd/fragments-user.svg?branch=master)](https://travis-ci.org/snd/fragments-user/branches)
[![Dependencies](https://david-dm.org/snd/fragments-user.svg)](https://david-dm.org/snd/fragments-user)

**have a token-auth protected API running within minutes with [fragments](https://github.com/snd/fragments)**


## commands

call `./app` to see a list of all available commands:

```
rights {user-id} - list the rights of user with `user-id`
rights:delete {user-id} {right} - revoke `right` from user with `id`
rights:insert {user-id} {right} - grant `right` to user with `id`
users [optional-user-id] - show all users or just the user with `optional-user-id` (if given)
users:delete {user-id} - delete user with `user-id`
users:insert {name} {email} {password} - insert user
fake:users {count} - insert `count` fake users
```

<!--
if you call `./app serve`
it starts a webserver whose callback
is `server`.

it has a user api

also brings commands insert, delete, list users 
grant rights

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

### TODO

- find a good name
- replace cockpit by that name

### requires the following env vars to be set

-->

## [license: MIT](LICENSE)
