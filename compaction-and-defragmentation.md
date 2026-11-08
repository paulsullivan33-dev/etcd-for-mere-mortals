# Compaction and defragmentation

Outcome: history you no longer need
actually thrown away, proved by the
cluster refusing to show it — and the
disk space that only a second, separate
step gives back.

## The store remembers — until you say stop

Every write raises the cluster revision,
and old versions stay readable: chapter
5's `--rev` can fetch the past. The lab
demonstrated on one key (transcript
`etcd-lab/transcripts/t07-compaction.txt`):
five writes, and the paperwork climbing
in step —

```
put one    create_rev 18  mod_rev 18  version 1
put two    create_rev 18  mod_rev 19  version 2
put three  create_rev 18  mod_rev 20  version 3
put four   create_rev 18  mod_rev 21  version 4
put five   create_rev 18  mod_rev 22  version 5
```

— and a read at revision 18 still
returned the first value, `one`, long
after it stopped being current. That
memory is what watches resume from and
what careful readers audit with. It is
also, left alone, growth without end.

## Compaction: forgetting on purpose

**Compaction** discards every version
older than a revision you name:

```
$ etcdctl compact 22
compacted revision 22
$ etcdctl get services/compaction-demo/value --rev=18
Error: etcdserver: mvcc: required revision has been compacted   (exit 1)
$ etcdctl get services/compaction-demo/value
five
```

The three lines are the whole contract.
History at or before 22 is gone, and
asking for it is an *error with a reason*,
not a silent empty result — a caller
holding an old revision learns it must
re-read current state and start over,
which is exactly how watch resumption
decides to reset. Current values are
untouched: `five` reads back as before.
Compact up to a revision you are sure
no reader still needs; production
clusters automate this on a schedule or
a revision window (an etcd server
setting, documented-only here), because
nobody compacts by hand at 3 a.m.

## Defragmentation: the space comes back separately

Compaction marks space free *inside*
etcd's storage file; the file itself
does not shrink. **Defragmentation**
rewrites it, member by member:

```
endpoint status before:  DB SIZE 25 kB, IN USE 20 kB  (m1)
$ etcdctl defrag   (all three endpoints)
Finished defragmenting etcd member[127.0.0.1:18085]. took 219ms
Finished defragmenting etcd member[127.0.0.1:18086]. took 205ms
Finished defragmenting etcd member[127.0.0.1:18087]. took 302ms
endpoint status after:   DB SIZE 20 kB, IN USE 12 kB  (all three)
```

Small numbers in a small lab, but the
mechanics are the real ones: compact
first to create the slack, defrag second
to return it, and check `DB SIZE` in
`endpoint status` either side to prove
the second step did what the first
could not. Defrag runs on one member at
a time and briefly makes that member
busy — on a real cluster it is done to
followers first and the leader last,
after moving leadership if needed
(chapter 10 showed how) — and never
during an outage, because a defragging
member is not voting while it works.

There is a hard edge behind all of this:
the store has a **quota** — the lab's
status output shows 2.1 GB — and a
cluster that fills it stops accepting
writes and raises an alarm until space
is freed. Compaction and defrag are how
you stay away from that wall;
chapter 16 covers meeting it anyway.

Check: write a key five times, read its
first revision back, compact to the
current revision, and confirm the old
read now fails with the compacted error
while the current value survives.
