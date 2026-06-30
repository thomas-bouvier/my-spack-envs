if [ -f /etc/zshrc ]; then
    . /etc/zshrc
fi

function use_cooley {
    if hostname | grep cooley &>/dev/null || hostname | grep cc &> /dev/null; then
        echo "Loading Spack for Cooley"
       soft add +gcc-8.2.0
       soft add +cmake-3.20.4
       soft add +cuda-11.0.2
       soft add +mvapich2
       source ${HOME}/git/spack-cooley/share/spack/setup-env.sh
       export clustername=cooley
    fi  
    export SPACK_USER_CONFIG_PATH="$HOME/.spack/$clustername"
    export SPACK_USER_CACHE_PATH="$SPACK_USER_CONFIG_PATH"
}

function use_thetagpu {
    if hostname | grep thetagpu &>/dev/null; then
       echo "Loading Spack for ThetaGPU"
       source ${HOME}/git/spack-thetagpu/share/spack/setup-env.sh
       export CRAYPE_LINK_TYPE=dynamic
       export clustername=thetagpu
       export HTTP_PROXY="http://theta-proxy.tmi.alcf.anl.gov:3128"
       export HTTPS_PROXY="http://theta-proxy.tmi.alcf.anl.gov:3128"
       export http_proxy="http://theta-proxy.tmi.alcf.anl.gov:3128"
       export https_proxy="http://theta-proxy.tmi.alcf.anl.gov:3128"
     fi
    export SPACK_USER_CONFIG_PATH="$HOME/.spack/$clustername"
    export SPACK_USER_CACHE_PATH="$SPACK_USER_CONFIG_PATH"
}

function use_polaris {
    if hostname -f | grep polaris &>/dev/null; then
        echo "Loading Spack for Polaris"
        source ${HOME}/git/spack-polaris/share/spack/setup-env.sh
        module swap PrgEnv-nvhpc PrgEnv-gnu
        module load nvhpc-mixed
        export HTTP_PROXY="http://proxy.alcf.anl.gov:3128"
        export HTTPS_PROXY="http://proxy.alcf.anl.gov:3128"
        export http_proxy="http://proxy.alcf.anl.gov:3128"
        export https_proxy="http://proxy.alcf.anl.gov:3128"
        export ftp_proxy="http://proxy.alcf.anl.gov:3128"
    fi
}

function use_sophia {
    if hostname -f | grep sophia &>/dev/null; then
        echo "Loading Spack for Sophia"
        source ${HOME}/git/spack-sophia/share/spack/setup-env.sh
        export HTTP_PROXY="http://proxy.alcf.anl.gov:3128"
        export HTTPS_PROXY="http://proxy.alcf.anl.gov:3128"
        export http_proxy="http://proxy.alcf.anl.gov:3128"
        export https_proxy="http://proxy.alcf.anl.gov:3128"
        export ftp_proxy="http://proxy.alcf.anl.gov:3128"
    fi
}
