# rails-interview / TodoApi

[![Open in Coder](https://dev.crunchloop.io/open-in-coder.svg)](https://dev.crunchloop.io/templates/fly-containers/workspace?param.Git%20Repository=git@github.com:crunchloop/rails-interview.git)

This is a simple Todo List API built in Ruby on Rails 7. This project is currently being used for Ruby full-stack candidates.

## Design

Figma design: https://www.figma.com/design/eLY9H4h1aKQrDZg7XmPIHE/To-do-list-project?node-id=2-3&t=Fy2LShduijHFx3Si-0

## Build

To build the application:

`bin/setup`

## Run the API

To run the TodoApi in your local environment:

`bin/puma`

## Test

To run tests:

`bin/rspec`

Check integration tests at: (https://github.com/crunchloop/interview-tests)

## Contact

- Santiago Doldán (sdoldan@crunchloop.io)

## About Crunchloop

![crunchloop](https://s3.amazonaws.com/crunchloop.io/logo-blue.png)

We strongly believe in giving back :rocket:. Let's work together [`Get in touch`](https://crunchloop.io/#contact).

## Nazareno Moresco 

### Pi Sessions

All Pi sessions are stored under `sessions/`. OpenCode was also used but only to help with commit messages, so those sessions are not stored. For a more selective list you can use the one below.

* [instruct agents to use conventional commits and local pi guidance](https://pi.dev/session/#957edce427477e9881b21c6c47a04037)
* [ignore playwright mcp files](https://pi.dev/session/#7836934b2b408bfdbb67f76c80b28571)
* [commit work during last interview](https://pi.dev/session/#c532bcf77b2b12e5176c65d1e99b3eca)
* [add mutant configuration](https://pi.dev/session/#f8f2ef95278b70910f8d83c8675f1419)
* [harden controller mutation coverage](https://pi.dev/session/#ca00b2808a8c42ee8e4b72a8e96289de)
* [add mutation coverage for timestamp boolean concern](https://pi.dev/session/#a5d1edb08016d366fd63e14e09b97c76)
* [route root path to todolists](https://pi.dev/session/#5ad1b68fae19daaa504a23c883de6a8d)
* [splitting base controllers for API and APP](https://pi.dev/session/#ff20020f2ad6bc3b91eadd044bbb99a0 )
* [support todo list and item parity between API and APP](https://pi.dev/session/#76daf530166821f841c1848ce05d9d0c)
* [run mutant for new API controller](https://pi.dev/session/#8c619c9fb10ca239e34505a6e40578f4)
* [route /todo_items not /items](https://pi.dev/session/#3b72d947bacefcd68f8201def24c51a5)
* implementing design
  * [first draft](https://pi.dev/session/#b27930b9f12768ae06f93d560c568fc8)
  * [refactor non-conventional controllers](https://pi.dev/session/#65f55a2312bfa6fce48a4a31dcb00e22)
  * [improve error message UI](https://pi.dev/session/#21f5c74fcb3bcaaff4b9bb27616ca677)
  * [order items](https://pi.dev/session/#1b2927abf9157f2359999f3286e4b44c)
* [add name presence validation to todo lists](https://pi.dev/session/#325f435b830cda960e1c2650c36d283e)
* [post-interview ask: deletion of items shouldn't refresh the whole page](https://pi.dev/session/#11ca901ce3889b4a68fa04e66986703f)
* [restore HTML responses](https://pi.dev/session/#169b431e98dad73f89256515e54c7618)
* [post interview ask: add a complete all action](https://pi.dev/session/#2fca8db64303862cc389902e8e4ec543)
  * [add an ugly white circle to fix contrast issues](https://pi.dev/session/#eeb2ca1d26786acc4966ca0b247fec50)

### Key decisions

* Use conventional commits: I observed it was being used when doing `git log`, I made it a standard for LLM agents by writing it down in the `AGENTS.md`.
* Using mutant testing: I wanted better quality tests before starting the new work.
* Routing the root path to todolists: It was very hard for a user to find the application without access to the source code.
* Splitting the base controllers for the API and the APP controllers. The (skip_before_action :verify_authenticity_token) didn’t belong in the API TodoLists controller as it’s something essential to all potential API controller in our project, but we want to keep the protection for the app, therefore we need different base controllers.
* Renaming nested item routes back to `todo_items`: We kept `todolists` for compatibility, but `items` had no such constraint and was less idiomatic than the Rails conventional `todo_items`, so I aligned both APP and API routes on the clearer name.
* No Authorization: I decided to not add Authorization. It depends on the use this project will have whether we need it or not. Since so far it doesn't have Authorization, it might be that the applications runs locally for users. One might argue that if would be local the API wouldn't make sense, but the users might find it useful to setup local automations in their machines. For now it will remain out of scope.
* Not using Inter as font: For simplicity and performance, we use the default font for system/browser.
* Adding name presence validations to TodoList.
* I decided to order items in a todo list by the completed attribute and the creation of the item. 

### Out of scope

* When checking an item the todo list should reorder.