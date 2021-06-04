FROM continuumio/miniconda3:4.9.2

# Get a copy of the lcls-lattice repository, and point
# the 'LCLS_LATTICE' environmental variable to it
COPY ./lcls-lattice /lcls-lattice
ENV LCLS_LATTICE /lcls-lattice

# Clone the repository and create the 'lume-test' conda environment
RUN git clone https://github.com/ChristopherMayes/lume-impact-live-demo.git
WORKDIR lume-impact-live-demo
RUN conda env create --file environment.yml

# Add the conda activate command to .bashrc script and make
# RUN commands use 'bash --login'. This will make all commands
# to run inside our 'lume-test' conda environment.
RUN echo "conda activate lume-test" > ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]

# Convert the jupyter notebook to python scripts
RUN jupyter nbconvert --to script lume-impact-live-demo.ipynb && \
    jupyter nbconvert --to script make_dashboard.ipynb && \
    jupyter nbconvert --to script get_vcc_image.ipynb

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

# Create an output directory
RUN mkdir -p /output/{plot,archive,output}

# Patch the top level python script to write all the output data to the
# output directory, instead of the current directory.
RUN sed -i -e 's|^ROOT = os.getcwd()\s*$|ROOT = "/output"|g' lume-impact-live-demo.py
RUN sed -i -e 's|{PREFIX}.log|/output/{PREFIX}.log|g' lume-impact-live-demo.py

# This should be or last working directory. The top level python script
# looks for files relative to this path.
WORKDIR /lume-impact-live-demo

# Define the entrypoint. We use a script in order to run the command
# under the 'lume-test' conda environment.
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
