# local/pdi-tutorial/cpu.ubuntu2404.spack

Use one of the following commands to generate a container recipe:

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

Finally, use one of these commands to generate a container:

```console
# Docker
docker build -t myimage .

# Apptainer
apptainer build Apptainer.sif Apptainer.def
```

## Future work

- gcc can't compile programs https://gcc.gnu.org/bugzilla/show_bug.cgi?id=119560