FROM jupyter/base-notebook:5811dcb711ba
#FROM jupyter/base-notebook:137a295ff71b

USER root
RUN apt-get update \
  && apt-get install -yq --no-install-recommends \
         libfuse-dev nano fuse vim git graphviz libgl1-mesa-glx \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/
USER $NB_USER

RUN $CONDA_DIR/bin/conda update conda --yes  

RUN $CONDA_DIR/bin/conda config --system --remove channels defaults

RUN $CONDA_DIR/bin/conda install --yes  \
    python=3.6 \
    intake::intake \
    intake::intake-xarray \
    bokeh/label/dev::bokeh \
    pyviz/label/dev::holoviews \
    pyviz/label/dev::hvplot \
    pyviz/label/dev::geoviews \
    pyviz/label/dev::panel \
    pyviz/label/dev::datashader \
    ipywidgets>=7.4.2 \
    pandas>=0.23.4 \
    jupyterlab=0.35.1 \
    ncurses=6.1 \
    cartopy \
    appmode \
    arrow \
    bqplot \
    cython \
    dask-kubernetes \
    dask-ml \
    dask-tensorflow \
    depfinder \
    easyargs \
    erddapy \
    esmpy \
    fastparquet \
    folium \
    fusepy \
    gcsfs \
    geolinks \
    geopandas \
    gitpython \
    gridgeo \
    ioos_tools \
    ipyleaflet \
    iris \
    ocefpaf::iris-grib \
    jupyter \
    jupyterlab_launcher \
    jupyter_client \
    jupyter_contrib_nbextensions \
    libiconv \
    lz4 \
    metpy \
    nbserverproxy \
    nb_conda_kernels \
    nbrr \
    opencv \
    owslib \
    palettable \
    pendulum \
    pyarrow \
    pygam \
    pynio \
    pyoos \
    pydensecrf \
    python-blosc \
    python-eccodes \
    python-graphviz \
    rasterio \
    retrying \
    rise \
    ruamel.yaml \
    satsearch \
    s3fs \
    scikit-image \
    scikit-learn \
    shapely \
    siphon \
    tensorflow \
    tensorflow-hub \
    tqdm \
    utide \
    websocket-client \
    xarray \
    xesmf \
    xgcm \
    xlrd \
    zarr \
    && $CONDA_DIR/bin/conda clean -tipsy

RUN pip install --upgrade pip

RUN pip install \
    python-gist \
    git+https://github.com/ericdill/depfinder.git \
    git+https://github.com/pyviz/EarthSim.git \
                --upgrade --no-cache-dir \
                --upgrade-strategy only-if-needed

RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager \
                                 @jupyterlab/hub-extension@0.12 \
                                 @pyviz/jupyterlab_pyviz \
                                 jupyter-leaflet \
                                 dask-labextension 

USER root
COPY prepare.sh /usr/bin/prepare.sh
RUN chmod +x /usr/bin/prepare.sh
RUN mkdir /home/$NB_USER/examples && chown -R $NB_USER /home/$NB_USER/examples
RUN mkdir /pre-home && mkdir /pre-home/examples && chown -R $NB_USER /pre-home

ENV DASK_CONFIG=/home/$NB_USER/config.yaml

COPY config.yaml /pre-home
COPY worker-template.yaml /pre-home

COPY examples/ /pre-home/examples/

RUN mkdir /s3 && chown -R $NB_USER /s3
RUN mkdir /opt/app

# Add NB_USER to sudo
RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
RUN sed -ri "s#Defaults\s+secure_path=\"([^\"]+)\"#Defaults secure_path=\"\1:$CONDA_DIR/bin\"#" /etc/sudoers
USER $NB_USER

ENTRYPOINT ["tini", "--", "/usr/bin/prepare.sh"]
CMD ["start.sh jupyter lab"]
