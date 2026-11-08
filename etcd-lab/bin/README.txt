This folder held the lab's etcd binaries during the build:
etcd, etcdctl and etcdutl from etcd-v3.7.3-linux-amd64.tar.gz
(official etcd GitHub release v3.7.3, sha256
5dfa9cc3b3ce3b4b491fbcc2057d3daa166bcc6676f743fcd20f8e5760cb9775).

The binaries are about 60 MB together and were removed from the
checkout to keep it small, exactly as the install chapter
describes. To re-run the lab, download that tarball, unpack it,
and copy the three binaries here. Every script in the lab finds
them at bin/etcd, bin/etcdctl and bin/etcdutl.
