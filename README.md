# TODO-BFF

An BFF type application written in Haskell using servent, wrap.

## Goals

To be a template project to bootstrap an web api/bff type app using onion layer architecture (controller, business, persistence)

The controller layer will be simple/lean entry point providing RESETful endpoints (JSON).
The business layer might follow DDD and event sourcing.
The presistence layer should be agnostic and support plugable design, Postgresql, Cassandra, CouchDb, etc.,

The below cross functional, reliable, scalable and observable features are a must

* Health check
* Metrics (Prometheus)
* Stateless
* Circuit breaker

## Build & Run

```
make
make test
make run
open http://localhost:18080

## Docker
make push # to push docker registry
```
