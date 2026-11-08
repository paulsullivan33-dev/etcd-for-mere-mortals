# Installing etcd

Outcome: etcd, etcdctl and etcdutl on
your machine, proved by the version
check — and one honest surprise this
version holds for people following older
tutorials.

## The check

However you install it, the proof is
three short commands:

```
etcd --version
etcdctl version
etcdutl version
```

The lab's copies answer (transcript
`etcd-lab/transcripts/t00-version.txt`):

```
etcd Version: 3.7.3
Git SHA: 0a173d0
Go Version: go1.26.10
Go OS/Arch: linux/amd64
etcdctl version: 3.7.3
API version: 3.7
etcdutl version: 3.7.3
API version: 3.7
```

If those do not run, nothing else in
this guide will either.

## The route the lab used: the release tarball

The project publishes ready-made files
for each release on its GitHub releases
page. The lab downloaded
`etcd-v3.7.3-linux-amd64.tar.gz` from
the v3.7.3 release, checked it
(SHA-256
`5dfa9cc3b3ce3b4b491fbcc2057d3daa166bcc6676f743fcd20f8e5760cb9775`,
recorded in the transcript), unpacked
it, and copied the three binaries into
the lab's own `bin/` folder — no
system-wide install:

```
tar -xzf etcd-v3.7.3-linux-amd64.tar.gz
cp etcd-v3.7.3-linux-amd64/{etcd,etcdctl,etcdutl} etcd-lab/bin/
```

The binaries are **statically linked**
(the transcript's `file` output says so
plainly): one self-contained program
each, no runtime libraries to install.
That is a genuine property of how etcd
is built, and it makes the tarball route
unusually painless. The unpacked folder
also carries documentation for each
tool. To use the commands everywhere,
put the binaries somewhere on your
`PATH` under their plain names. The
finished checkout removes the binaries
to keep itself small — `etcd-lab/bin/README.txt`
says what belonged there and how to put
it back.

## The surprise: ETCDCTL_API

Older tutorials begin with
`export ETCDCTL_API=3`, teaching
`etcdctl` to speak the version 3 API.
In 3.7.3 that variable is a leftover:
the lab's first run set it, and every
command printed a warning —
`unrecognized environment variable
ETCDCTL_API=3` — because the version 3
API is now simply what etcdctl speaks.
The lab removed the variable and the
warnings stopped. If a tutorial tells
you to set it and your copy warns you,
believe your copy: `etcdctl version`
outranks any tutorial, this one
included.

## The other routes, documented only

- **Distribution packages.** Many
  distributions package etcd; versions
  lag the releases page, sometimes by a
  lot, and the version check above is
  how you find out what you really got.
- **Containers.** The project publishes
  official container images for the same
  releases.
- **Building from source** needs a Go
  toolchain and gives you the least
  tested artefact of the three routes.

Whichever door you use, finish with the
check at the top.

Check: all three version commands print
3.7.x (or a newer version you chose on
purpose), and `file` on the server
binary reports a statically linked
executable.
