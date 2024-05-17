# Clone the CKAN extensions to use. In order for CKAN to find and load an extension
# at runtime, install them in the directory listed in the SRC_DIR environment variable.
# If you want to modify the extension code, install the full repo, specifying git branch to use
# for continued editing. Otherwise, clone only the relevant branch to use with a --depth of 1 to save space.
# If you need a specific commit that was not tagged or the HEAD of a particular branch, clone the
# entire branch containing the commit (i.e., omit the --depth 1 arguments), then change to the repo
# directory and checkout the commit using its hash code. 
# Any additional Python modules needed by the extensions will be installed by the /setup/start_ckan_development.sh
# script as long as they are named requirements.txt or pip-requirements.txt.
# Make sure to also list the extensions in the CKAN__PLUGINS environment variable in the .env file and add
# any other configuration options for the extensions in the .env file, too.
# Add any initialization scripts for the extensions in the docker-entrypoint.d folder, noting they are executed
# in the sort order of the script name.
[ -d $SRC_DIR ] || mkdir $SRC_DIR
cd $SRC_DIR


#git clone --branch ed-multi-saml --depth 1 https://github.com/datopian/ckanext-saml2auth.git

git clone 

