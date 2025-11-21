# ALCF

Copy the relevant content of `.zshrc` into the frontend `.zshrc`.

## Polaris

Change the default configuration if needed:

```console
spack config --scope defaults edit config
build_stage: /local/scratch/tbouvier/spack-stage
```

Compilations lasting for more than one hour should be performed in the `preemptable` queue.

```console
qsub -I -l select=1:ngpus=1:system=polaris -q preemptable -l walltime=04:00:00 -A VeloC -l filesystems=home
```

Once you are logged in on a compute node, activate the environment and install it:

```console
use_polaris
spack env activate git/spack-envs/polaris
spack install
```

From [this guide](https://github.com/mochi-hpc-experiments/platform-configurations/blob/main/ANL/Polaris/README.md).

### Programming environment

We recommend using the system-provided GNU compiler as specified in the
example spack configurations. The GNU compiler can also be loaded in
your normal terminal environment (outside of Spack) by running `module
swap PrgEnv-nvhpc PrgEnv-gnu`. You should also run `module
load nvhpc-mixed` to gain access to CUDA libraries that may be
required for executables built within this Spack environment.

### Networking

Polaris will use the `ofi+cxi://` transport in Mercury for native access to
the Slingshot network. The default environment includes a libfabric package
that is already properly configured to use it.  Note that this is only
available using the system libfabric libraries on Polaris; CXI (Slingshot)
support is not available in the upstream open source libfabric package.

This Spack environment also relies on system CUDA and Cray MPICH libraries.

### Job management

Polaris uses the PBS Pro workload manager. `job.qsub` is an example of job
file. Please modify the header to use your project allocation and set
relevant parameters. You can refer to ALCF documentation for more
information.

Once modified, the job script may be submitted as follows.

```
$ qsub ./job.qsub
```

### Notes

As of this writing (2024-03-15) it is best to use json-c 0.13 with Mochi in
order to ensure link time compatibility with the system json-c used by the
system libfabric and cray-mpich on Polaris. However, the json-c-devel
package is not installed on Polaris at this time, and 0.13 is not available
in upstream Spack, so this is a difficult combination to use for Mochi.

As a workaround, the mochi-spack-packages repo adds an additional json-c
version (labeled 0.13.0 to disambiguate from 0.13.1 which is already in
Spack).  We also add a dependency in the root spec in the spack.yaml to
ensure that this version is used on Polaris.

These instructions and environment examples will be updated if/when a
matching json-c-devel package is installed on Polaris in the system
environment.

### Last successful installations:

| Date | `spack-envs` commit | `spack-packages` commit | Spack commit | Notes |
|----------|----------|----------|----------|----------|
| 2024-09-28 | `44162d3` | `bbacb27` | `a8d02bd` | |
| 2024-01-25 | `20e8e76` | `ad655c1` | `d079aaa` | Contents of `spack-packages/packages/py-continuum/package.py` copied into `spack/var/spack/repos/builtin/packages/py-continuum/package.py` |



## ThetaGPU

From [this guide](https://github.com/mochi-hpc-experiments/platform-configurations/blob/main/ANL/ThetaGPU/README.md).

### Programming environment

We recommend using the default gcc, OpenMPI, and OFED packages on ThetaGPU
as specified in the provided spack.yaml file.  Note that you must use an
interactive allocation on ThetaGPU to compile code for ThetaGPU; it cannot
be done on the login nodes.  Here is an example of how to get an interactive
node for 1 hour:


```
module load cobalt/cobalt-gpu
qsub -I -n 1 -t 60 -A VeloC -q single-gpu
# set up spack environment
```

### Networking

ThetaGPU uses an InfiniBand network.  The corresponding transport in Mercury
is `verbs://`, using the `fabrics=rxm,verbs` variant in the libfabric package.

The `FI_MR_CACHE_MAX_COUNT` environment variable should be set to 0 to
disable the memory registration cache in the verbs provider; it has been
problematic in some libfabric releases.

The `FI_OFI_RXM_USE_SRX` envrionment variable should be set to 1 to enable
shared receive contexts; this is expected to improve scalability.

### Job management

Theta uses the Cobalt workload manager. `job.qsub` is an example
of job file. Please modify the header (lines starting with `#COBALT`)
to use your project allocation and set relevant parameters. You can
refer to ALCF documentation for more information.

Once modified, the job script may be submitted as follows.

```
$ qsub ./job.qsub
```
