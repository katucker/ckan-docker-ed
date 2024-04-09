#!/bin/sh

# This script looks for files in a volume named /srv/app/test-setup.
# Map a volume on the host computer to the /srv/app/test-setup directory,
# using the -v argument for the docker run command, to share test setup
# files between the host and container. 

# Use a custom certificate bundle if one is provided in the test-setup.
if [ -f /srv/app/test-setup/ca.crt ];
then
    export SSL_CERT_FILE=/srv/app/test-setup/ca.crt
    export REQUESTS_CA_BUNDLE=$SSL_CERT_FILE
fi

# Install the ckanext-ed extension to test.
# Note: The extension is expected to be stored in a ZIP file
# in the /srv/app/test-setup directory of the docker image. 
# Download the repo version to test and name it ckanext-ed.zip.
if [ -f /srv/app/test-setup/ckanext-ed.zip ];
then
    pip3 install -e /srv/app/test-setup/ckanext-ed.zip
fi

# Load the environment variables from a file in the /srv/app/test-setup
# directory.
if [ -f /srv/app/test-setup/.env ];
then
    set -a
    source /srv/app/test-setup/.env
fi

# Visit all the extension directories, installing any
# additional modules listed in pip-requirements.txt or
# requirements.txt files.
for i in $SRC_DIR/*
do
    if [ -d $i ];
    then

        if [ -f $i/pip-requirements.txt ];
        then
            pip install -r $i/pip-requirements.txt
            echo "Found requirements file in $i"
        fi
        if [ -f $i/requirements.txt ];
        then
            pip install -r $i/requirements.txt
            echo "Found requirements file in $i"
        fi
    fi
done

# Run any startup scripts provided by images extending this one
if [[ -d "/docker-entrypoint.d" ]]
then
    for f in /docker-entrypoint.d/*; do
        case "$f" in
            *.sh)     echo "$0: Running init file $f"; . "$f" ;;
            *.py)     echo "$0: Running init file $f"; python3 "$f"; echo ;;
            *)        echo "$0: Ignoring $f (not an sh or py file)" ;;
        esac
        echo
    done
fi

# Set the common uwsgi options
UWSGI_OPTS="--plugins http,python \
            --socket /tmp/uwsgi.sock \
            --wsgi-file /srv/app/wsgi.py \
            --module wsgi:application \
            --uid 92 --gid 92 \
            --http 0.0.0.0:5000 \
            --master --enable-threads \
            --lazy-apps \
            -p 2 -L -b 32768 --vacuum \
            --harakiri $UWSGI_HARAKIRI"

if [ $? -eq 0 ]
then
    # Start supervisord
    supervisord --configuration /etc/supervisord.conf &
    # Start uwsgi
    su -p ckan -c "uwsgi $UWSGI_OPTS"
else
  echo "[prerun] failed...not starting CKAN."
fi
