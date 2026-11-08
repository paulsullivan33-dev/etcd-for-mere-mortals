# Glossary

Outcome: every technical term in this
guide, in one place, in the words the
chapters used.

**Alarm** — a cluster-wide warning state,
raised for example when the store fills
its quota; writes are refused while the
NOSPACE alarm stands, until it is
disarmed.

**Client port** — the port where programs
and `etcdctl` talk to a member. The
lab's were 18085–18087.

**Cluster** — the set of members that
together run one etcd store.

**Cluster token** — a word shared by all
members of one cluster at founding, so
different clusters never merge by
accident.

**Commit** — the moment a proposed change
is held by a majority of members and
becomes permanent. Nothing is answered
from uncommitted data.

**Compaction** — discarding stored
versions older than a named revision.
Afterwards, reads at compacted revisions
fail with a named error.

**Defragmentation** — rewriting a
member's storage file to return
compacted space to the operating system.

**Election** — the vote by which living
members choose a leader when none
exists, held at the start of a new term.

**Endpoint** — one member's client
address, as named in `--endpoints`.

**etcdctl** — the command-line client
shipped with etcd; every procedure in
this guide drives it.

**etcdutl** — the offline file tool:
snapshot status and restore, with no
cluster running.

**Follower** — a member that is not the
leader; it receives the log from the
leader and votes in elections.

**Key** — the name under which a value
is stored, usually shaped like a path.

**Leader** — the one member through
which all writes travel, and which
copies each change to the followers.

**Learner** — a member catching up on
the log before becoming a voter; present
in the member list, not counted toward
any majority.

**Lease** — a grant of time; keys
attached to it are deleted by the
cluster when it is revoked or expires.

**Linearizable** — the default read
strength: the answer reflects only
committed, majority-agreed state.

**Log** — the ordered record of changes
the leader copies to every member; the
thing Raft keeps identical.

**Majority (quorum)** — more than half
the members: 2 of 3, 3 of 5. The unit of
chapter 1's rule.

**Member** — one running etcd process
belonging to the cluster, with its own
data directory.

**Peer port** — the port where members
talk to each other: log copying,
elections, health. The lab's were
18185–18187.

**Prefix read** — a `get --prefix` that
returns every key beginning with a
string, in key order.

**Quota** — the store's size ceiling
(2.1 GB in the lab's default build);
crossing it raises the NOSPACE alarm.

**Raft** — the consensus algorithm etcd
uses: a leader, a shared log, and
majority commit.

**Revision** — the store-wide counter
that rises with every write; each key
remembers its create and modification
revisions.

**Snapshot** — a complete copy of the
store at one revision, in a single file.

**Term** — the number of the current
leadership era; it rises with each
election or leadership transfer.

**Version (of a key)** — how many times
that one key has been written.

**Watch** — a standing request to be
told of every change to a key or prefix,
in revision order.

Check: pick five terms at random and
explain each without looking at the
chapters. The five you hesitate on are
the chapters to skim again.
