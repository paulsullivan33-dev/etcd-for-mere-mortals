# Writing criteria for this guide

Every "for Mere Mortals" guide is written to the same nine-point
standard, so a reader who trusts one can trust the rest. Here it
is, with the verification notes for this particular guide below.

1. **Fix it first.** Reader outcomes lead, not action items: each
   chapter opens by naming the outcome it delivers, shows a check
   the reader can run to confirm they got it, and a reasonable
   reader finishes able to state what was done, what it means,
   and what to try next.
2. **Plain language.** Short sentences, everyday vocabulary,
   technical terms defined on first use. No slang, and no
   idioms that only make sense in one country — the reader may
   be translating as they go.
3. **No dead ends.** A guide never tells the reader to do
   something it cannot show them how to verify. Every claim a
   reader relies on — an install, a command, an output — is
   something this guide demonstrates or clearly labels
   documented-only below.
4. **Live-verified where it matters.** Procedures are run for
   real in the guide's lab wherever the build machine allows it,
   and the transcripts kept in the repository are the evidence.
   What could not be run is listed honestly below, never
   presented as if it had been.
5. **General audiences.** Nothing in this guide — examples,
   fixtures, names, addresses — is modelled on any particular
   reader or author's real life, network, or organisations.
   The lab's traffic is the lab talking to itself.
6. **Standalone.** A reader needs this guide, its lab, and
   nothing else. Where another guide would genuinely help, it
   is pointed to once, by name, and the chapter still completes
   without it.
7. **Honest about limits.** The limits chapter names what the
   tool cannot do: it is a coordination store, not a database —
   values must stay small, the total store has a quota, and
   there are no queries over values and no joins; members must
   come in odd numbers because a majority must be winnable, and
   two members are worse than one, since a majority of two is
   two and tolerates no loss at all; losing a majority means
   refusal — reads included — by design, not graceful
   degradation; and the distance between members is latency
   charged to every write, because a write is only committed
   when the majority physically holds it.
8. **The one rule is in the text, early.** Chapter 1 and the
   README state the rule plainly — *etcd agrees with itself
   before it answers you: a write only counts as true once a
   majority of members hold it, which is why the cluster would
   rather refuse than disagree* — before any procedure depends
   on it, and later chapters point back to it where the rule
   bites: health checks that commit a proposal, leases whose
   expiry needs a quorum, snapshots that need only one member
   because every member holds the agreed whole, and the
   two-of-three refusal in chapter 9.
9. **Builds clean.** The site builds with MkDocs in strict mode
   with no warnings, and a fresh reader following the chapters
   in order reaches the stated outcome of each.

## Verification notes for this guide

The build machine is an Ubuntu 24.04 sandbox. etcd **3.7.3**
was the project's official release file for Linux
(`etcd-v3.7.3-linux-amd64.tar.gz` from the etcd-io/etcd GitHub
releases, SHA-256
`5dfa9cc3b3ce3b4b491fbcc2057d3daa166bcc6676f743fcd20f8e5760cb9775`),
run from the lab's own `bin/` folder rather than installed
system-wide. The binaries are statically linked Go programs;
no runtime dependencies were needed. The lab is in `etcd-lab/`:
a REAL three-member cluster — three etcd processes from the one
binary, three data directories, client ports 127.0.0.1:18085,
18086 and 18087, peer ports 127.0.0.1:18185, 18186 and 18187 —
with scripted, reproducible start and stop
(`start-cluster.sh`, `start-member.sh`, `stop-member.sh`,
`stop-cluster.sh`, `clean.sh`), driver scripts in `drivers/`,
a snapshot in `snapshots/`, and every transcript in
`transcripts/`. All fixtures are fictional service-discovery
data: invented services registering invented addresses under
`services/`. The binaries were removed from the finished
checkout to keep it small; `etcd-lab/bin/README.txt` records
what belonged there.

Run for real, with transcripts as evidence:

- Version capture for `etcd`, `etcdctl` and `etcdutl`, the
  tarball's checksum, and the static linking (t00), plus the
  `etcdctl` command list. Setting `ETCDCTL_API=3` under 3.7.3
  produced an "unrecognized environment variable" warning on
  every command; the lab removed it and chapter 3 says so.
- Cluster bring-up from `clean.sh` + `start-cluster.sh` (t01):
  member list showed all three members `started` with both
  address pairs; endpoint status showed exactly one leader
  (m2 in that run; m1 led later runs); endpoint health called
  all three healthy with "successfully committed proposal"
  in about 12 ms each.
- Put, get, delete and revisions (t02): three fictional
  services registered; a key read back as JSON showed header
  revision 4, create_revision 2, mod_revision 2, version 1;
  after one overwrite those were 5, 2, 5 and 2 respectively.
  A `--prefix services/` read returned all three keys in
  order; a delete answered 1 and the key then read empty;
  asking member m3 alone returned the same value as the
  cluster.
- Watch (t03): a watch on `services/web-frontend/status` ran
  in the background while a separate process put `ready`,
  put `draining` and deleted the key; the watch printed PUT,
  PUT and DELETE events in that order, with values on the
  puts and none on the delete.
- Leases (t04): a 30 s lease with a heartbeat key attached was
  revoked by hand and the key vanished; `lease timetolive
  --keys` had named the attached key with 29 s remaining. A
  10 s lease's key polled alive at t+0 through t+9 and was
  gone after a measured 10 s; its lease then reported
  "already expired".
- The quorum sequence (t05), the heart of the guide: with
  one member (m3) stopped, a put still succeeded in 95 ms
  and reads worked; with a second member (m2) stopped, the
  survivor's health check failed ("failed to commit
  proposal: context deadline exceeded"), a write **and a
  read** each failed with `Error: context deadline exceeded`
  (exit 1) under a 5 s command timeout, and the refused value
  never appeared. After restarting both members the cluster
  was healthy again, raft term had risen 2 to 4, all three
  raft indexes matched, the value written during the
  one-member outage was intact, and new writes succeeded.
- Snapshot (t06): `etcdctl snapshot save` fetched a 25 kB
  snapshot at revision 17; `etcdutl snapshot status` reported
  hash 4db478b7, 3 total keys, 25 kB; `etcdutl snapshot
  restore` produced a fresh data directory (snap db, one
  .snap file, one .wal file), inspected on disk.
- Compaction and defragmentation (t07): five writes to one
  key took its version 1 to 5 at revisions 18 to 22; a read
  at revision 18 returned the first value; after
  `compact 22` the same read failed with "etcdserver: mvcc:
  required revision has been compacted" (exit 1) while the
  current value survived; defragging all three members
  (about 205–302 ms each) took DB size from 25 kB to 20 kB.
- Moving leadership (t08): two ID spellings were refused in
  the open — hex with a `0x` prefix ("invalid syntax") and
  decimal ("value out of range") — before the bare hex form
  `cdcfd8c055b0177a` succeeded: "Leadership transferred from
  129ffdbf00b38533 to cdcfd8c055b0177a". The term rose 4 to
  5 and all three members agreed on raft index 59.

Documented only — described from the project's documentation
and `--help` text, not run, and the text does not claim
otherwise:

- A cluster spread across real machines, including advertise
  addresses that must be reachable between hosts, TLS between
  members and clients, and authentication (users, roles).
- Adding, removing or updating members mid-life, learner
  promotion, and replacing a member; the lab's three members
  were created together and the roster was only read.
- Starting a restored snapshot as a live cluster and serving
  traffic from it; the restore itself was run and inspected,
  the full disaster rehearsal was not.
- Lease keep-alive streams (the `--once` and streaming
  renewals behind the heartbeat pattern); grant, attach,
  revoke and timed expiry were run.
- Watch resumption after a disconnection, and reading from a
  revision captured before a disconnect.
- Serializable (possibly stale) reads; all lab reads were
  the default linearizable kind — which is why the lone
  survivor's read refused in t05.
- Server-side automatic compaction settings, the NOSPACE
  alarm and its disarm procedure (the quota and the compact
  and defrag steps it depends on were run; the alarm itself
  was not raised), and raising the store quota.
- Transactions (`txn`), the `lock` and `elect` concurrency
  commands, `make-mirror`, and client libraries for any
  programming language.
- The neighbouring tools in chapter 14 are characterised,
  not benchmarked.

Fixtures are this guide's own and deliberately generic: three
invented services (a web frontend, a cache, a billing worker)
registering addresses under the reserved `.example.test`
domain, heartbeat keys, and a quorum-check key. No example is
modelled on any real person, network, service or organisation,
and every port used is on 127.0.0.1.
