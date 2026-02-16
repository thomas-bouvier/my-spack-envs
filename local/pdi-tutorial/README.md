# local/pdi-tutorial

This recipe allows to build a container including all dependencies needed by the following tutorial: https://github.com/pdidev/tutorial/blob/tutorial_HPCAsia/README.md.

The resulting container can be downloaded using one of the following commands:

```console
# Docker
docker pull ghcr.io/thomas-bouvier/numpex-pdi-tutorial:latest

# Podman
podman pull ghcr.io/thomas-bouvier/numpex-pdi-tutorial:latest
```

You can also target the version that was used at HPCAsia 2026 specifically using tag `HPCAsia2026`.

## Tricks to build such an image

Spack provides the `spack containerize > Dockerfile` command, allowing to transform a `spack.yaml` file given as input into a Dockerfile. However I found out that using this command produces a barely usable Dockerfile. This document exposes some tricks I used to build customized containers.

### Saving up space

Dockerfiles [produced by `spack containerize`](https://spack.readthedocs.io/en/latest/containers.html#generating-recipes-for-docker-and-singularity) leverage multi-stage builds. With multi-stage builds, you use multiple FROM statements in your Dockerfile. Each FROM instruction can use a different base, and each of them begins a new stage of the build. You can selectively copy artifacts from one stage to another, leaving behind everything you don't want in the final image. This is a great way to reduce the size of final containers. In this project, I use the following image for the the build process:

```dockerfile
# Build stage with Spack pre-installed and ready to be used
FROM docker.io/spack/ubuntu-noble:nightly AS builder
```

The base and final images can be selected from the `spack.yaml` file as follows:

```yaml
container:
  images:
    build: custom/cuda-13.0.1-ubuntu22.04:latest
    final: nvidia/cuda:13.0.1-base-ubuntu22.04
```

Of course you can modify the generated Dockerfile manually. In fact, I created a user manually in the final image as follows:

```dockerfile
ENV SERVICE_NAME="pdi"

RUN groupadd --gid 1001 $SERVICE_NAME \
    && useradd -u 1001 -g $SERVICE_NAME --shell /bin/false --no-create-home --home-dir /opt/$SERVICE_NAME $SERVICE_NAME \
    && mkdir -p /opt/$SERVICE_NAME /var/log/$SERVICE_NAME \
    && chown -R $SERVICE_NAME:$SERVICE_NAME /opt/$SERVICE_NAME /var/log/$SERVICE_NAME /entrypoint.sh /opt/environment_check_script.sh /opt/tutorial
```

To save space, gather all instructions in a single RUN command.

[dive](https://github.com/wagoodman/dive) is useful to explore each layer in an image, helping identify ways to shrink its size:

```console
# Docker
dive ghcr.io/thomas-bouvier/numpex-pdi-tutorial:latest

# Podman
dive ghcr.io/thomas-bouvier/numpex-pdi-tutorial:latest --source podman
```

### Using a binary cache to speed up image builds

Docker images are built with layers stacked on top of each other. Each layer represents a specific modification to the filesystem. The `spack install` command, although installing the entire Spack environment declared in `spack.yaml`, corresponds to a single Docker instruction <-> layer. As a result, failing to install a single package invalidates the entire Spack environment installation, and all packages will need to be recompiled.

Binary caches can be useful to tackle this issue, as packages already compiled will be downloaded from the given registry instead of getting compiled again.

```yaml
mirrors:
  numpex-spack-mirror:
    url: oci://ghcr.io/thomas-bouvier/numpex-spack-mirror
    access_pair:
      id_variable: OCI_USERNAME_VARIABLE
      secret_variable: OCI_PASSWORD_VARIABLE
```

However, binaray caches also introduce some complexity as they typically require users pushing binaries to be authenticated (notice the `access_pair` attribute). We need to pass such credentials to the build process, without make them persistent. I use [secret mounts](https://docs.docker.com/build/building/secrets/#secret-mounts) to consume secrets in the Dockerfile. The following `RUN` commands 1) install packages using the binary cache with authentication secrets being consumed, and 2) push the installed packages to the binary cache for reuse.

```dockerfile
# 1) Install the software, remove unnecessary deps
RUN --mount=type=secret,id=oci_username_variable \
    --mount=type=secret,id=oci_password_variable \
    export OCI_USERNAME_VARIABLE=$(cat /run/secrets/oci_username_variable) && \
    export OCI_PASSWORD_VARIABLE=$(cat /run/secrets/oci_password_variable) && \
    cd /opt/spack-environment && spack env activate . && \
    spack install --fail-fast --verbose -j1

# 2) Update build cache
RUN --mount=type=secret,id=oci_username_variable \
    --mount=type=secret,id=oci_password_variable \
    export OCI_USERNAME_VARIABLE=$(cat /run/secrets/oci_username_variable) && \
    export OCI_PASSWORD_VARIABLE=$(cat /run/secrets/oci_password_variable) && \
    cd /opt/spack-environment && spack env activate . && \
    spack buildcache push --update-index --tag latest numpex-spack-mirror
```

The following `build` command mounts the environment variables (`OCI_USERNAME_VARIABLE` and `OCI_PASSWORD_VARIABLE`) to secret IDs (`oci_username_variable` and `oci_password_variable`) as files in the build images. These files are located at `/run/secrets/oci_username_variable` and `/run/secrets/oci_password_variable`. If such secrets are not passed by the user, authentication to the binary cache will fail, resulting in a longer build time.

```console
OCI_USERNAME_VARIABLE=aaa OCI_PASSWORD_VARIABLE=zzz podman build -t ghcr.io/thomas-bouvier/numpex-pdi-tutorial:latest --secret id=oci_username_variable,env=OCI_USERNAME_VARIABLE --secret id=oci_password_variable,env=OCI_PASSWORD_VARIABLE .
```

Please note that the build cache mechanism will not be present in the final image. This is solely used to speed up the image build process.

### Patching Spack packages

When preparing images under a deadline, you will sometimes need to include Spack packages that have not been upstreamed in `spack-packages` yet. In this case, you should configure a custom Spack package repository in the build stage of your Dockerfile.

```dockerfile
# Configure a custom repo to serve patches
RUN spack repo create ~/custom_packages tbouvier.patches

RUN spack repo add ~/custom_packages/spack_repo/tbouvier/patches
```

Between these two commands, you can COPY the missing Spack recipes from the local project to the image to include them in the custom Spack repository:

```dockerfile
RUN ls ~/custom_packages/spack_repo/tbouvier/patches
RUN mkdir -p ~/custom_packages/spack_repo/tbouvier/patches/packages/py_py_spy && \
    mkdir -p ~/custom_packages/spack_repo/tbouvier/patches/packages/py_ray

COPY py_py_spy.package.py /root/custom_packages/spack_repo/tbouvier/patches/packages/py_py_spy/package.py
COPY py_ray.package.py /root/custom_packages/spack_repo/tbouvier/patches/packages/py_ray/package.py
```

In this example, I use custom recipes for packages `py-py-spy` and `py-ray`.

### Provide a compiler in the final image

Installing `gcc` using Spack does not produce a working installation in the final image. I think this is due to the fact that the system `gcc` is used in the image build process, so the `gcc` Spack package is not installed in the final image for some reason.

As a workaround, I use `gcc:15` as a final image:

```dockerfile
# Bare OS image to run the installed executables
FROM docker.io/gcc:15
```

We also enforce environment variables `CC` and `CXX` to point to this system `gcc`. This is not ideal.

```dockerfile
RUN { \
      echo '#!/bin/sh' \
      && echo '.' /opt/spack-environment/activate.sh \
      && echo 'export CC=/usr/local/bin/gcc' \
      && echo 'export CXX=/usr/local/bin/g++' \
      && echo '/opt/environment_check_script.sh' \
      && echo 'exec "$@"'; \
    } > /entrypoint.sh \
```

## Tricks to run the actual container

The final image can be ran as a container as follows:

```console
podman run -it ghcr.io/thomas-bouvier/numpex-pdi-tutorial:HPCAsia2026
```

User `pdi` that we configured earlier is available inside the container. To edit some code on your host machine using VSCodium for instance, you should use a volume as follows:

```console
podman run -v /path/to/tour/local/sources:/opt/pdi -it ghcr.io/thomas-bouvier/numpex-pdi-tutorial:HPCAsia2026
```

If this command doesn't work as it is, contact your sysadmin; they probably spend part of their time implementing security measures that annoy people. One way is to check if your user ID is standard with `id -u`. If it is very high, this is probably not the case.
