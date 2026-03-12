# 🖥️ Generic environments

These environments are not tailored for a specific hardware platform. Ideal to test stuff locally.

I like to work on this repository from inside a container:

```console
podman run -v /path/to/my-spack-envs:/root/my-spack-envs -v /path/to/spack-packages:/root/.spack/package_repos/fncqgg4 -it docker.io/spack/rockylinux9
```

To generate a container from a `spack.yaml`, simply use:

```console
spack containerize > Dockerfile
```
