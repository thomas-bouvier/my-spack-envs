# my-spack-envs

My reproducible Spack environments of some HPC platforms I use.

I like to work on this repository from inside a Spack container:

```console
podman run -v /path/to/my-spack-envs:/root/my-spack-envs -v /path/to/spack-packages:/root/.spack/package_repos/fncqgg4 -it docker.io/spack/rockylinux9
```


```console
git clone -c feature.manyFiles=true https://github.com/spack/spack.git ~/spack
git clone https://github.com/mochi-hpc/mochi-spack-packages.git ~/mochi-spack-packages
git clone https://github.com/thomas-bouvier/my-spack-envs.git ~/my-spack-envs
```
