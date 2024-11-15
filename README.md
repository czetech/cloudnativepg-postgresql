# CloudNativePG PostgreSQL images

This project maintains various [CloudNativePG] PostgreSQL container image
variants with additional extensions. The images are built from CloudNativePG
[PostgreSQL images][cloudnativepg-github] for all supported major and minor
versions of PostgreSQL that are supported by CloudNativePG along with the
specified extension(s), and are rebuilt daily.

The images are available on [Docker Hub][docker-hub]:

```
czetech/cloudnativepg-postgresql:<POSTGRESQL_VERSION>-<VARIANT_NAME>
```

A `VARIANT_NAME` is one of **currently supported variants:**

| Variant name          | Extensions | PostgreSQL |
|-----------------------|------------|------------|
| [pgmq](variants/pgmq) | [PGMQ]     | 14-17      |

If your desired extension is not listed, feel free to open an issue!

A `POSTGRESQL_VERSION` can be specified as either a major version (e.g., `17`)
or a minor version (e.g., `17.1`), with the optional addition of an OS name
`debian`, `bullseye`, or `bookworm` (e.g., `17-bullseye` or `17.1-bullseye`).
For more details, refer to
[the list of CloudNativePG images][cloudnativepg-registry].

There is no `latest` tag (as an image requires a specified variant). Example
usage for PostgreSQL 17 with the PGMQ extension:

```
czetech/cloudnativepg-postgresql:17-pgmq
```

## Build a variant

Each variant has its own Dockerfile located in the `variants/<VARIANT_NAME>`
directory. These Dockerfiles accept the `POSTGRESQL_VERSION` argument, along
with others (see the specific Dockerfile for details).

## Support

Professional support by [Czetech] is available at <hello@cze.tech>.

## Source code

The source code is available at
<https://github.com/czetech/cloudnativepg-postgresql>.

[cloudnativepg]: https://cloudnative-pg.io/
[cloudnativepg-github]: https://github.com/cloudnative-pg/postgres-containers
[cloudnativepg-registry]: https://github.com/cloudnative-pg/postgres-containers/pkgs/container/postgresql
[czetech]: https://www.cze.tech/
[docker-hub]: https://hub.docker.com/r/czetech/cloudnativepg-postgresql
[pgmq]: https://github.com/tembo-io/pgmq
