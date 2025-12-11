# Build stage with Spack pre-installed and ready to be used
FROM spack/ubuntu-noble:latest AS builder


# What we want to install and how we want to install it
# is specified in a manifest file (spack.yaml)
RUN mkdir -p /opt/spack-environment && \
set -o noclobber \
&&  (echo spack: \
&&   echo '  view: /opt/views/view' \
&&   echo '  concretizer:' \
&&   echo '    unify: true' \
&&   echo '  # add package specs to the `specs` list' \
&&   echo '  specs:' \
&&   echo '  - cmake' \
&&   echo '  - kokkos' \
&&   echo '  - pdi~fortran' \
&&   echo '  - pdiplugin-decl-hdf5' \
&&   echo '  - pdiplugin-mpi' \
&&   echo '  - pdiplugin-pycall' \
&&   echo '  - pdiplugin-trace' \
&&   echo '  - pdiplugin-user-code' \
&&   echo '  - pdiplugin-set-value' \
&&   echo '  - python+tkinter' \
&&   echo '  - py-dask' \
&&   echo '  - py-distributed' \
&&   echo '  - py-bokeh' \
&&   echo '  - py-matplotlib' \
&&   echo '  - py-mpi4py' \
&&   echo '  - py-pip' \
&&   echo '  - py-pytest' \
&&   echo '  - git' \
&&   echo '  - gdb' \
&&   echo '  - gcc@14' \
&&   echo '  config:' \
&&   echo '    install_tree:' \
&&   echo '      root: /opt/software' \
&&   echo '  mirrors:' \
&&   echo '    numpex-spack-mirror:' \
&&   echo '      url: oci://ghcr.io/thomas-bouvier/numpex-spack-mirror' \
&&   echo '      access_pair:' \
&&   echo '        id_variable: OCI_USERNAME_VARIABLE' \
&&   echo '        secret_variable: OCI_PASSWORD_VARIABLE') > /opt/spack-environment/spack.yaml

# Install the software, remove unnecessary deps
RUN cd /opt/spack-environment && spack env activate . && spack install --fail-fast && spack gc -y

# Strip all the binaries
RUN find -L /opt/views/view/* -type f -exec readlink -f '{}' \; | \
    xargs file -i | \
    grep 'charset=binary' | \
    grep 'x-executable\|x-archive\|x-sharedlib' | \
    awk -F: '{print $1}' | xargs strip

# Modifications to the environment that are necessary to run
RUN cd /opt/spack-environment && \
    spack env activate --sh -d . > activate.sh

RUN git clone -b tutorial_HPCAsia https://github.com/pdidev/tutorial.git /root/tutorial


# Bare OS image to run the installed executables
FROM ubuntu:24.04

COPY --from=builder /opt/spack-environment /opt/spack-environment
COPY --from=builder /opt/software /opt/software
COPY --from=builder /opt/views /opt/views
COPY --from=builder /root/tutorial /root/tutorial

# Copy the validation script into the container
COPY environment_check_script.sh /opt/environment_check_script.sh
RUN chmod +x /opt/environment_check_script.sh

RUN { \
      echo '#!/bin/sh' \
      && echo '.' /opt/spack-environment/activate.sh \
      && echo '/opt/environment_check_script.sh' \
      && echo 'exec "$@"'; \
    } > /entrypoint.sh \
&& chmod a+x /entrypoint.sh \
&& ln -s /opt/views/view /opt/view

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/bin/bash" ]

