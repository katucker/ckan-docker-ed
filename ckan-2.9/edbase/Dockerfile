# Use the official CKAN image for version 2.9.
ARG CKAN_VERSION=2.9.10
FROM ckan/ckan-base:${CKAN_VERSION}

# Install any extensions needed by the base CKAN instance.
# Note: If you get an SSL error at this step of the build,
# you likely have a private certificate authority in use
# that is not trusted by the Python installation. To correct
# the issue, create a certificate file containing the
# certificate your computer trusts (probably issued by the
# private certificate authority), naming it ca.crt. Then uncomment
# the ADD and ENV lines and redo the build.
ADD ca.crt /etc/ssl/certs/ca-certificates.crt
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ADD extensions.sh ${APP_DIR}
RUN ${APP_DIR}/extensions.sh

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
