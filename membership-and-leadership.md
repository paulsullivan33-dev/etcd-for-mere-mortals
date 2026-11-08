# Membership and leadership

Outcome: you can read the cluster's own
list of who belongs to it, and move
leadership from one member to another —
including knowing which spelling of the
member ID the command demands, because
the lab got it wrong twice first.

## The member list is the roster

`etcdctl member list` (chapter 4) is not
a view of your configuration file. It is
the cluster's own committed roster:
names, IDs, peer and client addresses,
and whether each member is a full voter
or a **learner** — a member still
catching up on the log, present but not
yet counted toward any majority. A
member exists as far as the cluster is
concerned when it appears on that list,
not when its process starts.

Changing the roster — `member add`,
`member remove`, `member update` — are
themselves committed writes, which has
two consequences worth internalising.
They need a quorum like any other write,
so membership surgery during an outage
is mostly impossible (see chapter 16).
And order matters: the safe way to
replace a member is to add the new one,
let it catch up as a learner, then
remove the old one, never letting the
voter count pass through an even number
it does not have to. Those procedures
are documented-only in this guide: the
lab's three members were born together
in chapter 4 and none was added or
removed mid-life, and the text will not
pretend otherwise.

## Moving the leader

Leadership, unlike membership, is light:
any healthy member can lead, and the
cluster can be told to prefer one:

```
$ etcdctl move-leader <member-id>
```

The lab moved leadership from m1 to m3
(transcript
`etcd-lab/transcripts/t08-move-leader.txt`)
— eventually. The transcript keeps the
two refusals, because they teach the
interface faster than the success does:

```
$ etcdctl move-leader 0xcdcfd8c055b0177a
Error: strconv.ParseUint: parsing "0xcdcfd8c055b0177a": invalid syntax
$ etcdctl move-leader 14830310418537256826
Error: strconv.ParseUint: parsing "14830310418537256826": value out of range
$ etcdctl move-leader cdcfd8c055b0177a
Leadership transferred from 129ffdbf00b38533 to cdcfd8c055b0177a
```

The ID as printed by `member list` —
hexadecimal, **no `0x` prefix** — is the
form wanted. The decimal form the JSON
output carries overflows the parser;
the prefixed form is not parsed as a
number at all. Three spellings of one
fact, one accepted: worth knowing before
you need the command in a hurry.

After the move, `endpoint status` showed
m3 as leader, and two details certify
nothing broke: the **term rose from 4
to 5** (a transfer is an election by
appointment, and elections advance the
term), and all three members reported
the **same raft index, 59** — the new
leader's history identical to the old
one's, to the entry. Leadership is an
office, not a copy of the data; the data
never moved at all.

Why move a leader at all? To free the
current leader for maintenance, or to
put leadership on the machine nearest
most clients — writes travel to the
leader, so its location is latency for
every writer.

Check: read your cluster's member list,
pick the ID of a non-leader (hex, no
prefix), move leadership to it, and
confirm with `endpoint status`: new
leader, term up by one, raft indexes
still identical.
