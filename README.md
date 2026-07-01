# my-spack-envs

My reproducible Spack environments for the HPC platforms I use.

| Facility | Machine | Sub-dir | GPU | Environment purpose |
| --- | --- | --- | --- | --- |
| ALCF | Polaris | alcf/polaris/a100.nanotron/ | A100 (cuda_arch=80) | LLM training with Nanotron |
| ALCF | Polaris | alcf/polaris/a100.neomem/ | A100 (cuda_arch=80) | Neomem continual learning |
| ALCF | ThetaGPU | alcf/thetagpu/a100.neomem/ | A100 (cuda_arch=80) | Neomem continual learning (older, CUDA 11) |
| GENCI | Jean Zay | genci/jeanzay/a100.ai-inference/ | A100 | vLLM AI inference serving |
| Grid'5000 | Chifflot | grid5000/chifflot/p100.neomem/ | P100 (cuda_arch=60) | Neomem continual learning |
| Grid'5000 | Chifflot | grid5000/chifflot/v100.neomem/ | V100 (cuda_arch=70) | Neomem continual learning |
| Grid'5000 | Gemini | grid5000/gemini/v100.neomem/ | V100 (cuda_arch=70) | Neomem continual learning |
| MDLS | Mandelbrot | mdls/mandelbrot/rtx6000.ai-inference/ | RTX 6000 Ada (cuda_arch=120) | vLLM AI inference serving |
| Generic | any | generic/neomem/ | CUDA (aarch64 dev) | NeoMem local dev |
| Generic | any | generic/kénotron/ | A100 (cuda_arch=80) | Kénotron 4D-parallel LLM training (containerized) |
| Generic | any | generic/gysela-mini-app-io/ | — | GYSELA mini-app I/O |
| Containerized | Docker/Apptainer | containerized/ubuntu2404.pdi-tutorial/ | — | PDI tutorial container (HPCAsia 2026) |

## Workflows

I like to work on this repository from inside a container:

```console
podman run -v /path/to/my-spack-envs:/root/my-spack-envs -v /path/to/spack-packages:/root/.spack/package_repos/fncqgg4 -it docker.io/spack/rockylinux9:develop
```

You can also use a more stable Spack version:

```console
podman run -v /path/to/my-spack-envs:/root/my-spack-envs -v /path/to/spack-packages:/root/.spack/package_repos/fncqgg4 -it docker.io/spack/rockylinux9
```

To update package recipes, simply use `spack repo update`.
