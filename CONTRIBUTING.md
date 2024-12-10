# Contributing

Thank you for your interest in contributing to the CloudNativePG PostgreSQL
Images project!
This project aims to be a central hub for a collection of PostgreSQL container
images tailored for use with CloudNativePG, enhanced with various extensions.
It thrives mainly on contributions and collaboration from the community.
Whether you're reporting bugs, suggesting new features, improving documentation,
or contributing code,
your input plays a crucial role in the success of this project.

For smooth collaboration, please review this guide, which outlines the process
for contributing, our standards, and helpful resources.

## pre-commit

To ensure consistent code quality and simplify collaboration,
this project uses a set of formatters and linters applied to most of the code.
These tools are configured as [pre-commit] hooks.
While they are validated during CI, it is recommended to set them up locally,
as doing so provides instant feedback and helps streamline your workflow.

### Installing pre-commit Hooks

You can install `pre-commit` using your distribution's package manager if
available, or from [PyPI][pre-commit-pypi]:

```shell
pip install pre-commit
```

To set up the hooks, run the following command:

```shell
pre-commit install
```

Once installed, the hooks will automatically run before each commit.

If you encounter an issue, such as a linting message you can’t resolve, you can
temporarily bypass the hooks by committing with the `-n` (`--no-verify`) flag:

```shell
git commit -n
```

This allows you to create a pull request, and the maintainers will assist you in
fixing the issue during the review process.

## Adding a New Variant

1. Create a directory with the variant's name inside the `variants/` directory.
1. Inside the new variant directory, create a Dockerfile that builds the image
   based on [PostgreSQL images][cloudnativepg-github].
   See [pgmq variant's Dockerfile](variants/pgmq/Dockerfile) as an example.
1. Add a `test_image.sh` script to the variant directory. This script is used to
   test the built image and ensure it functions as expected. The image is built
   before the script is run and is stored in the `IMAGE` environment variable.
   See [pgmq variant's test_image.sh](variants/pgmq/test_image.sh) as an
   example.
1. Create a `config.yaml` file to the variant directory with a filter-tags key,
   which should contain a regular expression to filter the supported PostgreSQL
   image tags for the variant.
   See [pgmq variant's config.yaml](variants/pgmq/config.yaml) as an example.
1. Update the README.md file by adding the new variant to the variants table.

[cloudnativepg-github]: https://github.com/cloudnative-pg/postgres-containers
[pre-commit]: https://pre-commit.com/
[pre-commit-pypi]: https://pypi.org/project/pre-commit/
