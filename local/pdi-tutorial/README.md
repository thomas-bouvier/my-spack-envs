# local/pdi-tutorial

This recipe allows to build a container including all dependencies needed by the following tutorial: https://github.com/pdidev/tutorial/blob/tutorial_HPCAsia/README.md.

The resulting container can be downloaded using one of the following commands:

```
# Docker
docker pull ghcr.io/thomas-bouvier/numpex-pdi-tutorial:latest

# Podman
podman pull ghcr.io/thomas-bouvier/numpex-pdi-tutorial:latest
```

You can also target the version that was used at HPCAsia 2026 specifically using tag `HPCAsia2026`.

## Tricks to build such an image

Spack provides the `spack containerize > Dockerfile` command, allowing to transform a `spack.yaml` file given as input into a Dockerfile. However I found out that using this command produces a barely usable Dockerfile. This document exposes some tricks I used to build customized containers.

### Saving up space

Dockerfiles [produced by `spack containerize`](https://spack.readthedocs.io/en/latest/containers.html#generating-recipes-for-docker-and-singularity) leverage multi-stage builds. With multi-stage builds, you use multiple FROM statements in your Dockerfile. Each FROM instruction can use a different base, and each of them begins a new stage of the build. You can selectively copy artifacts from one stage to another, leaving behind everything you don't want in the final image. This is a great way to reduce the size of final containers.

The base and final images can be selected from the `spack.yaml` file as follows:

```yaml
  container:
    images:
      build: custom/cuda-13.0.1-ubuntu22.04:latest
      final: nvidia/cuda:13.0.1-base-ubuntu22.04
```

Of course you can modify the generated Dockerfile manually. In fact, I created a user manually in the final image as follows:

```yaml
ENV SERVICE_NAME="pdi"

RUN groupadd --gid 1001 $SERVICE_NAME \
    && useradd -u 1001 -g $SERVICE_NAME --shell /bin/false --no-create-home --home-dir /opt/$SERVICE_NAME $SERVICE_NAME \
    && mkdir -p /opt/$SERVICE_NAME /var/log/$SERVICE_NAME \
    && chown -R $SERVICE_NAME:$SERVICE_NAME /opt/$SERVICE_NAME /var/log/$SERVICE_NAME /entrypoint.sh /opt/environment_check_script.sh /opt/tutorial
```

To save space, gather all instructions in a single RUN command.

[dive](https://github.com/wagoodman/dive) is useful to explore each layer in an image, helping identify ways to shrink its size:

```
# Docker
dive ghcr.io/thomas-bouvier/numpex-pdi-tutorial:latest

# Podman
dive ghcr.io/thomas-bouvier/numpex-pdi-tutorial:latest --source podman
```

### Using a binary cache to speed up container builds

Docker images are built with layers stacked on top of each other. Each layer represents a specific modification to the filesystem. The `spack install` command, although installing the entire Spack environment declared in `spack.yaml`, corresponds to a single Docker instruction <-> layer. As a result, failing to install a single package invalidates the entire Spack environment installation, and all packages will need to be recompiled.

Binary caches can be useful to tackle this issue, as packages already compiled will be downloaded instead of compiled again. However they introduce some complexity as binary caches typically require users pushing binaries to be authenticated.

I use [secret mounts](https://docs.docker.com/build/building/secrets/#secret-mounts) to consume secrets in the Dockerfile. The following `RUN` commands 1) install packages using the binary cache with authentication secrets being consumed, and 2) push the installed packages to the binary cache for reuse.

```
# Install the software, remove unnecessary deps
RUN --mount=type=secret,id=oci_username_variable \
    --mount=type=secret,id=oci_password_variable \
    export OCI_USERNAME_VARIABLE=$(cat /run/secrets/oci_username_variable) && \
    export OCI_PASSWORD_VARIABLE=$(cat /run/secrets/oci_password_variable) && \
    cd /opt/spack-environment && spack env activate . && \
    spack install --fail-fast --verbose -j1

# Update build cache
RUN --mount=type=secret,id=oci_username_variable \
    --mount=type=secret,id=oci_password_variable \
    export OCI_USERNAME_VARIABLE=$(cat /run/secrets/oci_username_variable) && \
    export OCI_PASSWORD_VARIABLE=$(cat /run/secrets/oci_password_variable) && \
    cd /opt/spack-environment && spack env activate . && \
    spack buildcache push --update-index --tag latest numpex-spack-mirror
```

The following `podman build` command mounts the environment variables `OCI_USERNAME_VARIABLE` and `OCI_PASSWORD_VARIABLE` to secret IDs `oci_username_variable` and `oci_password_variable`, as files in the build container at `/run/secrets/oci_username_variable` and `/run/secrets/oci_password_variable`. If such secrets are not passed by the user, authentication to the binary cache will fail, resulting in a longer build time.

```
OCI_USERNAME_VARIABLE=aaa OCI_PASSWORD_VARIABLE=zzz podman build -t ghcr.io/thomas-bouvier/numpex-pdi-tutorial:latest --secret id=oci_username_variable,env=OCI_USERNAME_VARIABLE --secret id=oci_password_variable,env=OCI_PASSWORD_VARIABLE .
```

### Patching Spack packages

If you want to use custom Spack recipes not upstreamed in `spack-packages` yet.

### Provide a compiler in the final image

Installing `gcc` using Spack does not produce a working installation in the final image, so we use `gcc:15` as a final image. We also enforce environment variables `CC` and `CXX` to point to this system `gcc`. This is not ideal.

