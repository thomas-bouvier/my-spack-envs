# Grid5000

If you encounter errors related to your storage quota being filled up during compilation, change the default configuration as follows:

```console
spack config --scope defaults:base add config:build_stage:/tmp/spack-stage
```

You can also edit the config file manually as follows:

```console
spack config --scope defaults:base edit config
```

You may set the `install_tree` to [Group Storage](https://www.grid5000.fr/w/Group_Storage) over NFS:

```console
ln -s /srv/storage/my-group-storage@storage1.lyon.grid5000.fr/ /my-spack
spack config --scope defaults:base add config:install_tree:root:/my-spack/spack
```
