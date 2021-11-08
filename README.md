OpenBSD ZIG_LIBC support
========================

Simple shell script to build a `ZIG_LIBC` environment for [Zig](https://ziglang.org/) targeting [OpenBSD](https://www.openbsd.org/).

Usage
-----

```
$ ./build-ziglibc.sh
usage: ./build-ziglibc.sh url output-dir
```

- *url* : URL pointing to OpenBSD sets.

  Typical url to use: https://cdn.openbsd.org/pub/OpenBSD/*version*/*platform*/

  Please note that OpenBSD officially support only the two last
  released versions. Snapshots url is also valid for targeting
  -current, but be aware that it is a moving target.

  Refer to [supported platforms](https://www.openbsd.org/plat.html)
  list from OpenBSD site web for the name used.

- *output-dir* : where to put the environment.

  Prefer absolute path: it will be used in generated `libc.conf` file.

  The directory will be created.


Examples of url
---------------

- OpenBSD 6.9 [amd64](https://www.openbsd.org/amd64.html) (x86_64 on Linux world)

  https://cdn.openbsd.org/pub/OpenBSD/6.9/amd64/

- OpenBSD -current [i386](https://www.openbsd.org/i386.html)

  https://cdn.openbsd.org/pub/OpenBSD/snapshots/i386/


Use the environment
-------------------

```
$ ZIG_LIBC=path/to/amd64/libc.conf zig build-exe -target x86_64-openbsd -o test/helloz test/hello.zig
$ ZIG_LIBC=path/to/amd64/libc.conf zig cc -target x86_64-openbsd -o test/helloc test/hello.c
```

Make shell wrapper
------------------

For easy use of crosscompilation, you could create a shell wrapper
named `x86_64-openbsd-cc`:

```
#!/bin/sh
exec env ZIG_LIBC=path/to/amd64/libc.conf zig cc -target x86_64-openbsd "$@"
```

And do the same for `x86_64-openbsd-c++`, `x86_64-openbsd-ar`, …
