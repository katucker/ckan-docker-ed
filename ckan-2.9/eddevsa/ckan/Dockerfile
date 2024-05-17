FROM edbase

# Copy custom initialization scripts. A custom Certificate Bundle can also be stored
# here as ca.crt. Do this action first so any custom Certificate Bundle will be
# available for any subsequent build steps.
COPY docker-entrypoint.d/* /docker-entrypoint.d/

# Copy secondary initialization scripts. Some initialization steps in the
# above folder may not succeed with the ED extensions enabled, so this
# secondary set of initialization scripts is used to initialize the
# instance further after the initialization without the ED extensions is
# done. These initialization scripts are used when the ED extensions are enabled.
COPY docker-secondary-entrypoint.d/* /docker-secondary-entrypoint.d/

# Override the certificate bundle if there's a replacement file in the src folder.
# Any pip commands attempted without this step may fail in an environment that
# uses a custom Certificate Authority.
#RUN if [ -f $SRC_EXTENSIONS_DIR/ca.crt ]; \
#    then \
#        export SSL_CERT_FILE=$SRC_EXTENSIONS_DIR/ca.crt ;\
#        export REQUESTS_CA_BUNDLE=$SSL_CERT_FILE ;\
#    fi

    # Install any extensions needed by your CKAN instance
# - Make sure to add the plugins to CKAN__PLUGINS in the .env file
# - Also make sure to provide all extra configuration options, either by:
#   * Adding them to the .env file (check the ckanext-envvars syntax for env vars), or
#   * Adding extra configuration scripts to /docker-entrypoint.d folder) to update
#      the CKAN config file (ckan.ini) with the `ckan config-tool` command
#
# See README > Extending the base images for more details
#
# For instance:
#
### XLoader ###
#RUN pip3 install -e 'git+https://github.com/ckan/ckanext-xloader.git@master#egg=ckanext-xloader' && \ 
#    pip3 install -r ${APP_DIR}/src/ckanext-xloader/requirements.txt && \
#    pip3 install -U requests[security]

### Harvester ###
#RUN pip3 install -e 'git+https://github.com/ckan/ckanext-harvest.git@master#egg=ckanext-harvest' && \
#    pip3 install -r ${APP_DIR}/src/ckanext-harvest/pip-requirements.txt
# will also require gather_consumer and fetch_consumer processes running (please see https://github.com/ckan/ckanext-harvest)

### Scheming ###
#RUN  pip3 install -e 'git+https://github.com/ckan/ckanext-scheming.git@master#egg=ckanext-scheming'

### Pages ###
#RUN  pip3 install -e git+https://github.com/ckan/ckanext-pages.git#egg=ckanext-pages

### DCAT ###
#RUN  pip3 install -e git+https://github.com/ckan/ckanext-dcat.git@v0.0.6#egg=ckanext-dcat && \
#     pip3 install -r https://raw.githubusercontent.com/ckan/ckanext-dcat/v0.0.6/requirements.txt

# Clone the extension(s) your are writing for your own project in the `src` folder
# to get them mounted in this image at runtime

# Apply any patches needed to CKAN core or any of the built extensions (not the
# runtime mounted ones)
COPY patches ${APP_DIR}/patches

RUN for d in $APP_DIR/patches/*; do \
        if [ -d $d ]; then \
            for f in `ls $d/*.patch | sort -g`; do \
                cd $SRC_DIR/`basename "$d"` && echo "$0: Applying patch $f to $SRC_DIR/`basename $d`"; patch -p1 < "$f" ; \
            done ; \
        fi ; \
    done