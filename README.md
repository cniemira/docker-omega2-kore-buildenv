# docker-omega2-kore-buildenv

This Dockerfile creates a cross compiler environment to build [kore](https://github.com/jorisvink/kore) and kore projects for the [Onion](https://onion.io) Omega2 and Omega2+.

It will build a `kore` with support for HTTP, Python, and TLS.

The `kodev` utility is also built, but it won't be useful because it will be compiled for the Omega system.


## Usage

Instead of using `kodev` to build a runable project, add a `Makefile` to the source directory (see below) and run the cross compiler thusly:

	docker run -v /host/path:/mnt omega2-kore-buildenv

This will launch the image and run `make` with the correct arguments in the mounted folder, hopefully compiling you an .so and delivering a copy of `kore`. Bundle up your project, install it on an Omega, and run it.


# Example Makefile

	MODULE=monte.so

	SOURCES = src/monte.c
	OBJECTS= $(SOURCES:src/%.c=src/%.o)

	all: $(MODULE) kore

	$(MODULE): $(OBJECTS)
		$(CC) $(OBJECTS) -shared -o $(MODULE)

	src/%.o: src/%.c
		$(CC) $(CFLAGS) -fPIC -g -c $< -o $@

	clean:
		find . -type f -name \*.o -exec rm {} \;
		rm -rf $(MODULE)
		rm kore

	kore:
		cp $(PREFIX)/bin/kore .

	.PHONY: all clean

