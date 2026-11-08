# Putting, getting and deleting

Outcome: the three everyday verbs work
in your hands, and you can read the
three revision numbers every key
carries — the numbers later chapters'
history, watches and compaction all
trade in.

The fixture throughout is an invented
service registry: fictional programs
registering where they can be reached.
No real service, network or organisation
appears anywhere in it.

## Put and get

(transcript
`etcd-lab/transcripts/t02-put-get-delete.txt`)

```
$ etcdctl put services/web-frontend/endpoint frontend-01.example.test:8080
OK
$ etcdctl put services/cache/endpoint cache-01.example.test:6379
OK
$ etcdctl get services/web-frontend/endpoint
services/web-frontend/endpoint
frontend-01.example.test:8080
```

`put` answers a bare `OK` — but remember
what that `OK` means under chapter 1's
rule: the write was copied to a majority
of members and committed before the
answer came back. `get` prints the key,
then the value, on separate lines. Keys
are plain text and are usually shaped
like paths — `services/<name>/<fact>` —
not because etcd has folders (it does
not; the slashes are just characters in
one long name) but because chapter 6's
prefix reads turn that shape into a
filing system.

Keys and values are both just bytes to
etcd. Values are expected to be small —
a name, an address, a short status — and
chapter 15 holds the sizes honestly.

## The three numbers on every key

Ask for JSON and a key shows its
paperwork:

```
$ etcdctl get services/web-frontend/endpoint -w json
"header":  { "revision": 4, "raft_term": 2, ... }
"kvs": [ { "create_revision": 2,
           "mod_revision": 2,
           "version": 1, ... } ]
```

- **revision** (in the header) is the
  whole store's change counter at the
  moment of your read — 4 here, because
  four writes had happened in this young
  cluster.
- **create_revision** is the store
  revision at which this key first
  appeared.
- **mod_revision** is the revision of
  its most recent write.
- **version** counts writes to this key
  alone.

One overwrite, and the transcript shows
exactly which numbers move:

```
$ etcdctl put services/web-frontend/endpoint frontend-02.example.test:8080
OK
... "revision": 5 ... "create_revision": 2, "mod_revision": 5, "version": 2
```

Create stays 2 (the key is the same
key), modification climbs to 5, version
becomes 2. JSON output also shows keys
and values base64-encoded — that is the
wire format being honest about bytes;
the plain output is the same data
decoded for you.

## Delete, and the silence that proves it

```
$ etcdctl del services/cache/endpoint
1
$ etcdctl get services/cache/endpoint
(exit 0, no output)
```

`del` answers with a count of keys
removed, and a `get` for a key that does
not exist is not an error — it prints
nothing and succeeds. Scripts must check
for empty output, not for failure. The
transcript's last act is quiet and
important: asking a *different member*
(endpoint 18087 only) for a surviving key
returned the same value. There is no
"the copy on m3" to consult — agreement
means any member answers for the whole
cluster, or, chapter 9, none does.

Check: put a key, overwrite it, and read
its JSON. Create revision unchanged,
modification revision and version each
up by the writes you made. Then delete
it and confirm the empty get.
