# Docker container with all tools in order to build GNU software on Debian 7 Wheezy

This is one really old build environment that allows to compile against GLIBC 2.13

This is a GNU build container image.

# Custom libraries and binaries that are compiled and installed manually

All of the following tools and libraries are installed into `/usr/local`

Build tools

- autoconf  (2.71)
- gettext   (0.20)
- texinfo   (7.0.3)
- curl      (8.0.1)
- wget      (1.21)

Libraries:
- zlib      (1.2.13)
- gmp       (6.2.1)
- expat     (2.5.0)
- nettle    (3.4.1)
- openssl   (1.1.1t)
- libxml    (2.9.1) (test suite: xmlts20130923)
- libidn    (1.41)
- libidn2   (2.3.4)
- libntlm   (1.6)
- gss       (1.0.3)
- libgsasl  (1.10.0, because 2.0.0 is dropping symbols)


# starting points

```
make debug
./download.sh
./build.sh
exit
```

- Makefile
- Dockerfile
- download.sh
- build.sh
