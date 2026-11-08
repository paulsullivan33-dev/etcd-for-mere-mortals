# The neighbours

Outcome: the nearby tools placed
honestly beside etcd — what each is for,
where its centre of gravity differs, and
the one-line test for choosing. These
are characterisations from each
project's own description, not
benchmarks; none of the neighbours was
run in this lab.

## Consul

HashiCorp's **Consul** starts from the
same coordination ground — a consensus
cluster, a key-value store, health —
and builds *outward* into service
networking: service discovery with
health checks built in rather than
lease-based, DNS and HTTP interfaces to
the registry, and a service mesh for
connecting services to each other. If
your job is chapter 13's registry and
you want the health checking, the DNS
name for each service, and the mesh
handled by one system, Consul is the
broader tool. If you want only the
agreed store — and especially if your
world already runs Kubernetes, whose
own store is etcd — the smaller tool
fits.

## ZooKeeper

Apache **ZooKeeper** is the elder of
this family: the coordination service
much of the Hadoop-era world was built
on, with a similar shape — an ensemble
of servers, a leader, majority agreement
— and a more file-system-like model of
nodes (znodes), watches, and sessions
that leases resemble. It is proven,
widely deployed, and carries the weight
of its era: a Java service with its own
operational culture. New designs tend to
meet it through systems that embed it
rather than by adopting it directly, but
anyone maintaining those systems will
recognise every idea in this guide wearing
older names — the concepts transferred
because the underlying problem, majority
agreement, is the same.

## The store inside Kubernetes

Kubernetes keeps all of its state in
etcd — which is less a neighbour than
etcd's largest tenant. Two consequences
follow for mere mortals. If you operate
Kubernetes, you already depend on this
guide's subject, and its quorum chapter
is your cluster's failure behaviour
whether you chose it or not. And if you
are choosing a store for your own
programs *inside* Kubernetes, the usual
answer is to use Kubernetes' own objects
and let its etcd stay an internal
detail, rather than running a second
etcd beside it.

## What is not a neighbour

A general database (PostgreSQL, MySQL)
answers a different question — bulk
data, queries, relations — and chapter
15 explains why neither tool substitutes
for the other. A single-node key-value
store (Redis used alone, a local file)
is faster and simpler precisely because
it skips the majority: fine when
disagreement or loss is acceptable,
wrong tool when it is not. The choice is
never really about speed. It is about
what a written fact must *mean*.

Check: for a job you know, say which
neighbour's centre of gravity matches it
— registry-plus-networking (Consul),
an existing ZooKeeper estate, or the
bare agreed store (etcd) — and what you
would be giving up in the others.
