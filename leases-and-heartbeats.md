# Leases and heartbeats

Outcome: keys that delete themselves —
on your word, or on a timer you watch
expire to the second — and an
understanding of why a registration you
do not have to clean up is worth more
than one you do.

## The lease: a key with a deadline

A **lease** is a grant of time. You ask
the cluster for one, you attach keys to
it, and while the lease lives the keys
live. When the lease ends — you revoke
it, or its time runs out — every
attached key is deleted by the cluster
itself, as one committed event, watchers
and all. Nothing about the key remembers
to clean up; the lease is the memory.

The lab ran both endings (driver
`etcd-lab/drivers/t04-lease.sh`,
transcript
`etcd-lab/transcripts/t04-lease.txt`).

**Ending one: revoke by hand.** A
30-second lease, a heartbeat key
attached, its state examined, then:

```
lease grant 30 -> lease 0533a1b7fc50e514 granted with TTL(30s)
put services/heartbeat/node-a alive --lease=0533a1b7fc50e514  -> OK
get services/heartbeat/node-a  -> alive
lease timetolive 0533a1b7fc50e514 --keys
  -> granted with TTL(30s), remaining(29s), attached keys([services/heartbeat/node-a])
lease revoke 0533a1b7fc50e514 -> lease revoked
get services/heartbeat/node-a  -> (empty: the key is gone)
```

Note the `timetolive` report: a lease
can always name its remaining time and
its attached keys, which is how you
audit what will vanish when it ends.

**Ending two: let it expire.** A
10-second lease, a second heartbeat key,
and a polling loop with a clock:

```
  t+0s: still alive
  ...
  t+9s: still alive
key gone after 10s
lease timetolive ... -> already expired
```

Ten seconds granted, key gone after a
measured 10 seconds. Not "about ten" —
the transcript polls once a second and
the key survived every poll up to its
term and no poll after it.

## Keeping a lease alive: the heartbeat

A lease with a longer job to do is kept
alive by **keepalive**: the holder asks
the cluster to restart the lease's clock,
repeatedly, for as long as the holder is
healthy. `etcdctl lease keep-alive
<id>` does exactly that (one renewal
with `--once`, a stream without it).
This is the heartbeat pattern, and it is
how service registration stays honest:
a program registers under a lease and
keeps the lease alive while it serves;
if it crashes, hangs, or is cut off from
the cluster, the renewals stop, the
lease lapses, the registration deletes
itself, and chapter 6's prefix reads stop
offering a dead service — with nobody
writing cleanup code and no stale entry
waiting to be discovered the hard way.

The lab demonstrated grant, attach,
revoke and measured expiry live, and
shows keepalive only as the documented
mechanism it is: the driver kept leases
short instead of renewing them, which is
the stricter test of the expiry path.

One warning that belongs in this
chapter: expiry is itself a cluster
write, so it obeys chapter 1's rule — a
cluster that has lost its majority
cannot process expiries either. A lease
is a promise kept by a quorum, not by a
clock on one machine.

Check: grant a 10-second lease, attach
a key, and time its disappearance with
a polling loop of your own. Then grant
30 seconds and revoke at 5, and confirm
the key dies at your word, not the
timer's.
