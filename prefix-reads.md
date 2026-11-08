# Prefix reads

Outcome: one command reads a whole
branch of keys at once — the operation
that turns a pile of registrations into
a directory a program can actually use.

## The registrar's trick

Chapter 5's keys share a shape:
`services/<name>/endpoint`. A **prefix
read** asks for every key beginning with
a string, and etcd treats the key space
as one sorted list, so a prefix is a
contiguous run:

```
$ etcdctl get --prefix services/
services/billing-worker/endpoint
worker-01.example.test:9000
services/cache/endpoint
cache-01.example.test:6379
services/web-frontend/endpoint
frontend-02.example.test:8080
```

(transcript
`etcd-lab/transcripts/t02-put-get-delete.txt`.)

The answers arrive in key order. Add
`--keys-only` and you get the directory
listing without the contents — the
transcript shows the three service
names with blank values suppressed into
a clean list. Useful companions, all
present in the same command family:
`--limit N` caps how many keys return,
and `--rev N` reads the branch *as it
was* at an older revision, the history
chapter 12 will compact away.

## Why this is the service-discovery read

This one operation is most of what
**service discovery** needs. A program
starting up asks "what is registered
under `services/`?" and receives every
live registration in one agreed answer —
not one member's opinion, the cluster's,
committed under the rule. A program
looking for one service asks for its
narrower prefix, `services/cache/`, and
gets every fact that service published
about itself: endpoint, version, status,
whatever keys it chose to register.

Two disciplines make it work in
practice, and both are conventions, not
features. First, everyone agrees the
key shape in advance — `services/` is a
social contract the cluster cannot
enforce. Second, registrations must not
outlive the programs they describe; a
prefix read full of dead services is
worse than an empty one. That second
discipline has a mechanism, and it is
chapter 8: register under a lease, and
the registration removes itself when the
program stops proving it is alive.

There is deliberately no more query
power here. No filtering by value, no
"endpoints where version is 2", no
joins between branches. You fetch a
branch and sort it out yourself, in
your own program. Chapter 15 returns to
why that narrowness is the design, not
an omission.

Check: register three services of your
own invention, read them back with one
`get --prefix`, then read just the names
with `--keys-only`. One command each —
that economy is the point.
