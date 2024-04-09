FROM edbase

# Install the scripts to setup and run CKAN.
ADD setup/prerun.py ${APP_DIR}
ADD setup/start_ckan_test.sh ${APP_DIR}
RUN chmod +x $APP_DIR/start_ckan_test.sh

# Copy custom initialization scripts
COPY docker-entrypoint.d/* /docker-entrypoint.d/

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

EXPOSE 5000

# Create a volume for sharing test configuration between the
# host and container.
RUN mkdir ${APP_DIR}/test-setup
VOLUME ${APP_DIR}/test-setup

# Copy any files in the host's test-setup directory to
# the image.
COPY test-setup/* ${APP_DIR}/test-setup/
RUN chown -R ckan:ckan $APP_DIR/test-setup

CMD ["/srv/app/start_ckan_test.sh"]