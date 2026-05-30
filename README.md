# rails-interview / TodoApi

[![Open in Coder](https://dev.crunchloop.io/open-in-coder.svg)](https://dev.crunchloop.io/templates/fly-containers/workspace?param.Git%20Repository=git@github.com:crunchloop/rails-interview.git)

This is a simple Todo List API built in Ruby on Rails 7. This project is currently being used for Ruby full-stack candidates.

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

### Key decisions

* Use conventional commits: I observed it was being used when doing `git log`, I made it a standard for LLM agents by writing it down in the `AGENTS.md`.
* Using mutant testing: I wanted better quality tests before starting the new work.
* Routing the root path to todolists: It was very hard for a user to find the application without access to the source code.