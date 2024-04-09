# Open Data Platform Docker configurations


## 1.  Overview

This is a set of configuration and setup files to build and run CKAN instances extended for the U.S. Department of Education's Open Data Platform.

The images build on the official CKAN images maintained in the [ckan-docker](https://github.com/ckan/ckan-docker-base) repository.

Rather than using a Docker compose setup to run a complete set of images for CKAN, PostgreSQL, Solr and Redis locally, some of the images in this set assume the ancillary services are already running elsewhere and are initialized. Thus, only Docker files for the CKAN images are included.

A docker compose configuration is also provided for development on a single computer.

## 2.  Build and run images

#### EDBase image

The EDBase image contains CKAN and all the extensions used in the U.S. Department of Education's (ED) instance, except for the ED extension itself. The purpose of this image is to serve as a base for ongoing development and testing of the ED extension. This image is used as the starting point for all the other images in this collection.

This image is based on `ckan/ckan-base:<version>`, a base image located in the DockerHub repository, that has CKAN installed along with all its core dependencies, properly configured and running on [uWSGI](https://uwsgi-docs.readthedocs.io/en/latest/) (production setup) That base image defines environment variables APP_DIR, pointing to directory /srv/app in the image, and SRC_DIR, pointing to the src directory under APP_DIR. The CKAN application is installed in APP_DIR.

  * All the base extensions used by ED (except the ED extension) are cloned in the SRC_DIR directory, where CKAN expects to find extensions. The additional modules listed in a `requirements.txt` (or `pip-requirements.txt`) file are not installed in the process of building this base image. As a result, the CKAN application will not properly start if attempting to run this image in a container.
  
To build the image, run the commands below.

    cd edbase
	docker build -t edbase .

#### EDTest image

Use this image if you want to test changes to any of the extensions beyond the edbase image.

To build the image, first build the edbase image above, or `docker pull` it from Docker hub, then run the commands below.

    cd edtest
    docker build -t edtest .

 To dynamically pass test configuration to a container running the image, map a volume on the host computer to /srv/app/test-setup in the container. A shell script is executed upon starting a container based on this image that looks for specific files in that mapped volume.

 * ckanext-ed.zip is installed using pip if it exists in the mapped volume. This approach supports downloading the ED extension repo as a ZIP file and loading it at container runtime.

 * .env is sourced as a shell script, ostensibly to set environment variables for the test system. The CKAN configuration uses the envvars extension, so this .env file can be used to set CKAN parameters.

 * ca.crt is set as the Certificate Bundle for Transport Layer Security (TLS) to use. This is useful if running the container within the ED environment that uses a custom Certificate Authority. Store the certificate for the Certificate Authority in a file named ca.crt to overcome SSL/TLS errors.

 The image depends on an `.env` file for configuration options. A file named `.env.example` is included in the test-setup directory to use as a starting point. Copy and rename that file to `.env` in the folder mapped to the test-setup volume described above and edit as needed. Using the default values on the `.env.example` file will not get you a working CKAN instance. Since this image uses other services (PostgreSQL, Solr, and Redis) not installed in the image, the configuration settings must be edited to specify the locations and accounts for those other services. The edited `.env` file should replace everything surrounded by angle brackets, including the angle brackets, with the appropriate value for your specific environment. For example, in the line starting with `CKAN_SQLALCHEMY_URL`, the text `<ckan-user-id>` should be replaced with `ckanuser` if that's the name of an account in the PostgreSQL database with privileges to write to the CKAN database.

 Similarly, the image does not contain any release of the ED CKAN extension. As noted above, the CKAN extension to test must be stored as a file named ckanext-ed.zip in the host computer folder mapped to the test-setup volume.

 The startup shell script also performs a `pip install -r` on all `requirements.txt` or `pip-requirements.txt` files found in any of the installed CKAN extension folders. This ensures the Python modules required for all the base CKAN extensions as well as the specific extension to test are installed when the container starts.
 
 ### Minimal Development image

Use this image if you are making code changes to CKAN, creating new extensions, or making code changes to existing extensions.

To build the image, first build the edbase image above, or `docker pull` it from Docker hub, then run the commands below.

    cd eddev
    docker build -t eddev .

This image installs only the CKAN application and its extensions, and uses an `.env` file for configuration options to specify the locations and accounts for the PostgreSQL, Solr and Redis services. The image is useful for development on a computer with limited resources, using other computers or cloud services to provide the resource-intensive services.    

Similar to the edtest image, this image runs a shell script at container startup to install the required files for a development environment. In addition to running `pip install -r` on `requirements.txt` and `pip-requirements.txt` files found in the installed CKAN extensions, the script also pip installs any moduels list in `dev-extensions.txt` files.

To facilitate development, a container running this image should map a host computer folder to `/srv/app/src` to share source code files between the host and container.

##### Create an extension

You can use the ckan [extension](https://docs.ckan.org/en/latest/extensions/tutorial.html#creating-a-new-extension) instructions to create a CKAN extension within a container running this image, using the following commands:

    docker eddev run
    docker eddev exec /bin/sh -c "ckan generate extension --output-dir /srv/app/src_extensions"
    
The new extension files and directories are created in the `/srv/app/src_extensions/` folder in the running container. They will also exist in the local src/ directory as local `/src` directory is mounted as `/srv/app/src_extensions/` on the ckan container. You might need to change the owner of its folder to have the appropiate permissions.

##### Running HTTPS on development mode

Sometimes is useful to run your local development instance under HTTPS, for instance if you are using authentication extensions like [ckanext-saml2auth](https://github.com/keitaroinc/ckanext-saml2auth). To enable it, set the following in your `.env` file:

  USE_HTTPS_FOR_DEV=true

and update the site URL setting:

  CKAN_SITE_URL=https://localhost:5000

After recreating the `ckan-dev` container, you should be able to access CKAN at https://localhost:5000



## 6. Extending the base images

You can modify the docker files to build your own customized image tailored to your project, installing any extensions and extra requirements needed. For example here is where you would update to use a different CKAN base image ie: `ckan/ckan-base:<new version>`

To perform extra initialization steps you can add scripts to your custom images and copy them to the `/docker-entrypoint.d` folder (The folder should be created for you when you build the image). Any `*.sh` and `*.py` file in that folder will be executed just after the main initialization script ([`prerun.py`](https://github.com/ckan/ckan-docker-base/blob/main/ckan-2.9/base/setup/prerun.py)) is executed and just before the web server and supervisor processes are started.

For instance, consider the following custom image:

```
ckan
├── docker-entrypoint.d
│   └── setup_validation.sh
├── Dockerfile
└── Dockerfile.dev

```

We want to install an extension like [ckanext-validation](https://github.com/frictionlessdata/ckanext-validation) that needs to create database tables on startup time. We create a `setup_validation.sh` script in a `docker-entrypoint.d` folder with the necessary commands:

```bash
#!/bin/bash

# Create DB tables if not there
ckan -c /srv/app/ckan.ini validation init-db 
```

And then in our `Dockerfile.dev` file we install the extension and copy the initialization scripts:

```Dockerfile
FROM ckan/ckan-base:2.9.7-dev

RUN pip install -e git+https://github.com/frictionlessdata/ckanext-validation.git#egg=ckanext-validation && \
    pip install -r https://raw.githubusercontent.com/frictionlessdata/ckanext-validation/master/requirements.txt

COPY docker-entrypoint.d/* /docker-entrypoint.d/
```

NB: There are a number of extension examples commented out in the Dockerfile.dev file

## 7. Applying patches

When building your project specific CKAN images (the ones defined in the `ckan/` folder), you can apply patches 
to CKAN core or any of the built extensions. To do so create a folder inside `ckan/patches` with the name of the
package to patch (ie `ckan` or `ckanext-??`). Inside you can place patch files that will be applied when building
the images. The patches will be applied in alphabetical order, so you can prefix them sequentially if necessary.

For instance, check the following example image folder:

```
ckan
├── patches
│   ├── ckan
│   │   ├── 01_datasets_per_page.patch
│   │   ├── 02_groups_per_page.patch
│   │   ├── 03_or_filters.patch
│   └── ckanext-harvest
│       └── 01_resubmit_objects.patch
├── setup
├── Dockerfile
└── Dockerfile.dev

```

## 8. pdb

Add these lines to the `ckan-dev` service in the docker-compose.dev.yml file

![pdb](https://user-images.githubusercontent.com/54408245/179964232-9e98a451-5fe9-4842-ba9b-751bcc627730.png)

Debug with pdb (example) - Interact with `docker attach $(docker container ls -qf name=ckan)`

command: `python -m pdb /usr/lib/ckan/venv/bin/ckan --config /srv/app/ckan.ini run --host 0.0.0.0 --passthrough-errors`

## 9. Datastore and datapusher

The Datastore database and user is created as part of the entrypoint scripts for the db container. There is also a Datapusher container 
running the latest version of Datapusher.

## 10. NGINX

The base Docker Compose configuration uses an NGINX image as the front-end (ie: reverse proxy). It includes HTTPS running on port number 8443. A "self-signed" SSL certificate is generated as part of the ENTRYPOINT. The NGINX `server_name` directive and the `CN` field in the SSL certificate have been both set to 'localhost'. This should obviously not be used for production.

Creating the SSL cert and key files as follows:
`openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=DE/ST=Berlin/L=Berlin/O=None/CN=localhost" -keyout ckan-local.key -out ckan-local.crt`
The `ckan-local.*` files will then need to be moved into the nginx/setup/ directory

## 11. envvars

The ckanext-envvars extension is used in the CKAN Docker base repo to build the base images.
This extension checks for environmental variables conforming to an expected format and updates the corresponding CKAN config settings with its value.

For the extension to correctly identify which env var keys map to the format used for the config object, env var keys should be formatted in the following way:

  All uppercase  
  Replace periods ('.') with two underscores ('__')  
  Keys must begin with 'CKAN' or 'CKANEXT', if they do not you can prepend them with '`CKAN___`' 

For example:

  * `CKAN__PLUGINS="envvars image_view text_view recline_view datastore datapusher"`
  * `CKAN__DATAPUSHER__CALLBACK_URL_BASE=http://ckan:5000`
  * `CKAN___BEAKER__SESSION__SECRET=CHANGE_ME`

These parameters can be added to the `.env` file 

For more information please see [ckanext-envvars](https://github.com/okfn/ckanext-envvars)

## 12. CKAN_SITE_URL

For convenience the CKAN_SITE_URL parameter should be set in the .env file. For development it can be set to http://localhost:5000 and non-development set to https://localhost:8443

## 13. Manage new users

1. Create a new user from the Docker host, for example to create a new user called 'admin'

   `docker exec -it <container-id> ckan -c ckan.ini user add admin email=admin@localhost`

   To delete the 'admin' user

   `docker exec -it <container-id> ckan -c ckan.ini user remove admin`

2. Create a new user from within the ckan container. You will need to get a session on the running container

   `ckan -c ckan.ini user add admin email=admin@localhost`

   To delete the 'admin' user

   `ckan -c ckan.ini user remove admin`

## 14. Changing the base image

The base image used in the CKAN Dockerfile and Dockerfile.dev can be changed so a different DockerHub image is used eg: ckan/ckan-base:2.9.9
could be used instead of ckan/ckan-base:2.10.1

## 15. Replacing DataPusher with XLoader

Check out the wiki page for this: https://github.com/ckan/ckan-docker/wiki/Replacing-DataPusher-with-XLoader

Copying and License
-------------------

This material is copyright (c) 2006-2023 Open Knowledge Foundation and contributors.

It is open and licensed under the GNU Affero General Public License (AGPL) v3.0
whose full text may be found at:

http://www.fsf.org/licensing/licenses/agpl-3.0.html
