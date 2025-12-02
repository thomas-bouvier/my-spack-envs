# local/pdi-tutorial/cpu.ubuntu2404.spack

Use on of the following commands to generate a container recipe

```console
# Docker
spack containerize > Dockerfile

# Apptainer
spack containerize > Apptainer.def
```

This will generate a Docker or Singularity recipe depending on the value set in the yaml config:

```yaml
container:
  # docker | singularity
  format: singularity
  images:
    os: "ubuntu:24.04"
    spack: latest
  strip: true
```

Change the following in the recipe:

```yaml
config:
  install_tree: /opt/software
```

to

```yaml
config:
  install_tree:
    root: /opt/software
```

Finally, use one of these commands to generate a container:

```console
# Docker
docker build -t myimage .

# Apptainer
apptainer build Apptainer.sif Apptainer.def
```