# `generic/pdi-tutorial/cpu.ubuntu2404.spack`

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
```

Finally, use one of these commands to generate a container:

```bash
# Podman
podman build -t ghcr.io/thomas-bouvier/numpex-pdi-tutorial:latest --format docker .

# Apptainer
apptainer build Apptainer.sif Apptainer.def
```
