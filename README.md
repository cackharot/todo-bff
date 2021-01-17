# TODO :: Web Api

A REST Web Api server in Haskell using chakra library.

## Goals

The business layer must follow DDD, Event Sourcing & CQRS.
The presistence layer should be agnostic and support plugable design, Postgresql, Cassandra, CouchDb, etc.,

Areas to explore:

- [ ] Event Sourced Domain Aggregates
- [ ] Persist domain events to event store
- [ ] Snapshotting the event stream store to reduce aggregates rebuilds
- [ ] Projection Store
- [ ] Stream API endpoints to stream any domain events from event store
- [ ] Integrate with message broker (RabbitMQ) to send Integration events
- [ ] Distributed domain aggregates (aka Actor) - requires cluster awarness, cloud-haskell

## Dependencies

- Prometheus
- Grafana
- PostgreSQL

## Build & Run

```bash
make
make test
make run
open http://localhost:18080
```
