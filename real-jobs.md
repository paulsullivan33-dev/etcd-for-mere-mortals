# Real jobs

Outcome: the parts assembled into the
job etcd is most often hired for — a
service registry that registers,
discovers, reacts, and cleans up after
death — with every step traceable to a
transcript where that step ran for real.

## The job: who is alive, and where

A small fleet of programs needs to find
each other and stop finding the dead.
Concretely, in the lab's invented world:
three services — a web frontend, a
cache, a billing worker — announce where
they can be reached, consumers look them
up, and an announcement withdraws itself
when its service stops.

## Registration: a put under a lease

Each service, at startup, does what
chapters 5 and 8 each taught half of:

```
lease=$(etcdctl lease grant 30 | awk '{print $2}')
etcdctl put services/web-frontend/endpoint frontend-01.example.test:8080 --lease=$lease
etcdctl lease keep-alive $lease &   # while the service is healthy
```

The registration and its lifetime are
the same object. No separate "unregister"
call exists to forget: death, crash or
silence all end the same way, with the
lease lapsing and the key deleting
itself — the lab measured that deletion
at exactly the granted 10 seconds in
chapter 8, and revocation by hand in the
same transcript.

## Discovery: one prefix read

A consumer joining the fleet runs
chapter 6's command and holds the whole
directory: `etcdctl get --prefix
services/` returned every registration
in key order, from any member, as one
committed answer. Narrow the prefix —
`services/cache/` — and it holds just
that service's published facts.

## Reaction: a watch on the branch

A consumer that must *react* — reroute
traffic, rebuild a routing table — pairs
the read with chapter 7's watch:
prefix-read once, then `watch --prefix
services/`. The lab's watch transcript
showed the event language this consumer
will speak: a `PUT` with the new value
when a service registers or moves, a
`DELETE` with no value when one goes
away — which is exactly the event a
service's lease expiry generates. Read,
then watch, and the consumer's picture
is never older than one event.

## The second job: configuration that moves once, everywhere

The same three moves — put, prefix-read,
watch — run a shared-configuration job:
settings under `config/<service>/...`,
written once by an operator, picked up
by every watcher at the moment of
commit rather than at the next restart.
Chapter 9's rule is what makes this safe
to trust: a watcher fires only on
committed, majority-held writes, so no
consumer ever acts on a setting the
cluster later disowns.

## The third job, named honestly: locks and elections

etcd offers ready-made `lock` and
`elect` commands (visible in the t00
command list) built from leases and
watches, for "only one of us does this
job" problems. They are named here and
not run: the lab verified the primitives
they stand on — leases with measured
expiry, watches with captured events,
quorum behaviour under loss — and
describing the composed commands from
the documentation, as documented-only,
beats pretending a lock was contended
when none was.

Check: assemble the registry yourself —
register two invented services under
leases, read them back with one prefix
read, watch the branch from a second
terminal, then kill one registration by
revoking its lease and see the `DELETE`
arrive at the watcher.
