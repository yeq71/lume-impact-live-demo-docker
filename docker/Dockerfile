FROM ubuntu:18.04

# Install system utilities
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install -y \
    git \
    wget \
    openssl \
    libssl-dev \
    python3 \
    python3-dev \
    python3-pip \
    gfortran \
    && rm -rf /var/lib/apt/lists/*

# Install cmake 3.20.3
RUN mkdir /usr/local/src/cmake
WORKDIR /usr/local/src/cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.20.3/cmake-3.20.3.tar.gz && \
    tar -zxf cmake-3.20.3.tar.gz && \
    cd cmake-3.20.3 && \
    ./bootstrap && make && make install

# Build openmpi from source
RUN mkdir /usr/local/src/openmpi
WORKDIR /usr/local/src/openmpi
RUN wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.1.tar.gz && \
    tar -zxf openmpi-4.1.1.tar.gz && \
    cd openmpi-4.1.1 && \
    ./configure --prefix=/usr/local && make all install
ENV LD_LIBRARY_PATH "/usr/local/lib:$LD_LIBRARY_PATH"

# PIP Packages
RUN pip3 install \
    pandas \
    pyepics \
    jupyterlab \
    ipykernel \
    scikit-image \
    h5py \
    pyyaml \
    distro

# Install impact-t
WORKDIR /usr/local/src
RUN git clone https://github.com/impact-lbl/IMPACT-T.git -b v2.2
WORKDIR IMPACT-T/src
RUN cmake -S . -B build -DUSE_MPI=ON && \
    cmake --build build && \
    cmake --build build --target install

# Install openPMD-beamphysics
WORKDIR /usr/local/src
RUN git clone https://github.com/ChristopherMayes/openPMD-beamphysics.git -b v0.5.2
WORKDIR openPMD-beamphysics
RUN python3 setup.py install

# Install distgen
# Note: doing pip3 install distgen will install a different package.
WORKDIR /usr/local/src
RUN git clone https://github.com/ColwynGulliford/distgen.git -b v0.4.5
WORKDIR distgen
RUN python3 setup.py install

# Install lume-impact
WORKDIR /usr/local/src
RUN git clone https://github.com/ChristopherMayes/lume-impact.git -b v0.6.1
WORKDIR lume-impact
RUN python3 setup.py install

# Get a copy of the lcls-lattice repository, and point
# the 'LCLS_LATTICE' environmental variable to it
COPY ./lcls-lattice /usr/local/src/lcls-lattice
ENV LCLS_LATTICE /usr/local/src/lcls-lattice

# Clone the lume-impact-live-demo repository, and process it
WORKDIR /usr/local/src
RUN git clone https://github.com/ChristopherMayes/lume-impact-live-demo.git
WORKDIR lume-impact-live-demo
# Convert the jupyter notebook to python scripts
RUN jupyter nbconvert --to script lume-impact-live-demo.ipynb && \
    jupyter nbconvert --to script make_dashboard.ipynb && \
    jupyter nbconvert --to script get_vcc_image.ipynb
# Modify the top level python script to write the output data to '/output'
RUN sed -i -e 's|^ROOT = os.getcwd()\s*$|ROOT = "/output"|g' lume-impact-live-demo.py
# Create an output directories
RUN mkdir -p /output/{plot,archive,output}

# We need to define these 2 variable to allow 'mpirun' to be run as 'root'
ENV OMPI_ALLOW_RUN_AS_ROOT 1
ENV OMPI_ALLOW_RUN_AS_ROOT_CONFIRM 1

# Setup our EPICS environment to be able to read PROD variables
ENV EPICS_PVA_SERVER_PORT 5075
ENV EPICS_PVA_BROADCAST_PORT 5076
ENV EPICS_PVA_AUTO_ADDR_LIST FALSE
ENV EPICS_PVA_ADDR_LIST "lcls-prod01:5068"
ENV EPICS_PVA_ADDR_LIST "${EPICS_PVA_ADDR_LIST} lcls-prod01:5063"
ENV EPICS_PVA_ADDR_LIST "${EPICS_PVA_ADDR_LIST} mcc-dmz mccas0.slac.stanford.edu"
ENV EPICS_CA_AUTO_ADDR_LIST NO
ENV EPICS_CA_ADDR_LIST "lcls-prod01:5068 lcls-prod01:5063 mcc-dmz"
ENV EPICS_CA_REPEATER_PORT "5069"
ENV EPICS_CA_SERVER_PORT "5068"
ENV EPICS_TS_NTP_INET "134.79.48.11"
ENV EPICS_IOC_LOG_INET "134.79.151.21"

# This should be or last working directory. The lume-impact-live-demo.py
# looks for files relative to this path.
WORKDIR /usr/local/src/lume-impact-live-demo

# Define the entrypoint
ENTRYPOINT ["python3", "/usr/local/src/lume-impact-live-demo/lume-impact-live-demo.py"]
