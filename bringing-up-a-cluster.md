# Bringing up a cluster

Outcome: a real three-member cluster
running from a script you can tear down
and rebuild at will — proved by the
member list, a leader, and three healthy
endpoints.

## One binary, three members

A member is one `etcd` process told six
things: its name, its data directory,
where to listen for clients, where to
listen for peers, the addresses of all
the peers including itself, and a shared
**cluster token** — a nonsense word all
members of one cluster carry, so two
clusters that ever meet do not merge by
accident. The lab's starting script,
`etcd-lab/start-member.sh`, holds the
whole lesson; one member's command,
with its folder substituted, is:

```
etcd --name m1 \
  --data-dir etcd-lab/data/m1.etcd \
  --listen-client-urls http://127.0.0.1:18085 \
  --advertise-client-urls http://127.0.0.1:18085 \
  --listen-peer-urls http://127.0.0.1:18185 \
  --initial-advertise-peer-urls http://127.0.0.1:18185 \
  --initial-cluster m1=http://127.0.0.1:18185,m2=http://127.0.0.1:18186,m3=http://127.0.0.1:18187 \
  --initial-cluster-token etcd-lab-token \
  --initial-cluster-state new
```

`--listen-*` is where the process binds;
`--advertise-*` is what it tells others
to dial. On one machine they match. On
real machines the advertise addresses
must be reachable by the others, and
most first-cluster failures live in that
difference. The `initial-cluster` string
is identical for all three members and
lists peer URLs only — clients never
appear in it.

A state note the script handles for you:
`new` is only true once. When a member
with an existing data directory starts,
it must say `--initial-cluster-state
existing`, or it tries to found a second
cluster on top of its own history. The
script checks whether the data directory
exists and chooses the word itself —
which is why the quorum chapter could
restart members with the same script
that created them.

## Starting, and the three proofs

```
cd etcd-lab
./clean.sh          # stops anything running, deletes old data
./start-cluster.sh  # starts m1, m2, m3, waits for health
```

`start-cluster.sh` starts all three and
polls `endpoint health` until the
cluster answers. The bring-up transcript
(`etcd-lab/transcripts/t01-bringup.txt`)
then takes the three proofs this guide
trusts:

**The member list** — three members, all
`started`, none a learner:

```
│ 129ffdbf00b38533 │ started │ m1 │ http://127.0.0.1:18185 │ http://127.0.0.1:18085 │ false │
│ 3fd60f2804cfb79c │ started │ m2 │ http://127.0.0.1:18186 │ http://127.0.0.1:18086 │ false │
│ cdcfd8c055b0177a │ started │ m3 │ http://127.0.0.1:18187 │ http://127.0.0.1:18087 │ false │
```

**A leader exists** — `endpoint status`
marks exactly one row `IS LEADER true`.
In the recorded bring-up that was m2;
on the lab's later starts it was m1.
*Which* member leads is not promised and
does not matter; that exactly one does
is the proof.

**Health, in the cluster's own words:**

```
127.0.0.1:18085 is healthy: successfully committed proposal: took = 12.456294ms
```

Read that sentence closely: healthy
means a test proposal was *committed* —
written through Raft and agreed by a
majority — not merely that a socket
answered. Health in etcd is chapter 1's
rule, probed.

Every `etcdctl` command in this guide
names its endpoints explicitly, all
three when order does not matter:

```
etcdctl --endpoints=127.0.0.1:18085,127.0.0.1:18086,127.0.0.1:18087 member list
```

Listing all three is a habit worth
keeping: your client then survives one
member being down, because it can ask
another — chapter 9 relies on exactly
that.

Stopping is `stop-member.sh m3` for one
or `stop-cluster.sh` for all; `clean.sh`
also wipes the data, and the next start
founds a fresh cluster at revision 1.

Check: `member list` shows three started
members, `endpoint status` shows exactly
one leader, and `endpoint health` calls
all three healthy. If all three hold,
you have a cluster — chapter 5 puts
something in it.
