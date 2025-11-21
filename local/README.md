# 🖥️ Locally

## Fedora

Change the default configuration if needed:

```console
spack config --scope defaults edit config
install_tree: $spack/opt/spack
build_stage: $spack/var/spack/stage
```

Activate the environment and install it:

```console
spack env activate ~/Dev/Spack/my-spack-envs/local
spack install
```

### Programming environment

Using Fedora Asahi Remix 40, make sure that dev tools are installed on the system:

```console
dnf group install "Development Tools"
dnf group install "Development Libraries"
dnf group install "C Development Tools and Libraries"
dnf install gcc-gfortran
```

### Last successful installations:

| Date | `spack-envs` commit | Spack commit |
|----------|----------|----------|
| 2024-01-15 | `` |  |
