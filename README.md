# my-spack-envs

My reproducible Spack environments of some HPC platforms I use.

| Computing facility | Environment | Spack environments | Description |
|----------|---------|---------------------|-------------|
| alcf | `nanotron` | `a100.polaris.spack` | Distributed training framework for large language models |
| alcf | `neomem` | `a100.polaris.spack`, `a100.thetagpu.spack` | Torch rehearsal backend to mitigate catastrophic forgetting with a focus on performance, written in C++ |
| genci | `inference` | `a100.jeanzay.spack` | Inference serving and deployment stack based on vLLM |
| genci | `skao` | | Square Kilometre Array Observatory data processing pipeline |
| grid5000 | `neomem` | `p100.chifflot.spack`, `v100.chifflot.spack`, `v100.gemini.spack` | Torch rehearsal backend to mitigate catastrophic forgetting with a focus on performance, written in C++ |
| generic | `kénotron` | `cpu.ubuntu2404.spack` |  Experimental fork of Nanotron, a minimalistic large language model 4D-parallelism training |
| generic | `neomem` | `cpu.fedora39.spack` | Torch rehearsal backend to mitigate catastrophic forgetting with a focus on performance, written in C++ |
| generic | `pdi-tutorial` | `cpu.ubuntu2404.spack` | Tutorial environment for the PDI data interface library |
| generic | `pdidev` | `cpu.ubuntu2204.spack`, `test-env/{mini,all}.spack` | PDI development environment and spack-based CI test images (16 variants) |

## Workflows

I like to work on this repository from inside a Spack container:

```console
podman run -v /path/to/my-spack-envs:/root/my-spack-envs -v /path/to/spack-packages:/root/.spack/package_repos/fncqgg4 -it docker.io/spack/rockylinux9
```

To update package recipes, simply use `spack repo update`.
