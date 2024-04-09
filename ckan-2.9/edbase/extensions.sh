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
git clone --branch ed --depth 1 https://github.com/katucker/ckanext-datajson.git

git clone --depth 1 https://github.com/katucker/ckanext-deadoralive.git

git clone --branch ed-dev/python3.6 --depth 1 https://github.com/katucker/deadoralive.git

git clone --branch v1.4.0 --depth 1 https://github.com/ckan/ckanext-harvest.git

git clone --branch v1.5.0 --depth 1 https://github.com/ckan/ckanext-showcase.git

# For the ckanext-pages extension, we need a specific commit from the main branch that was not tagged.
# The approach taken for this is to clone the entire repo main branch and then checkout the specific commit.
git clone --branch master https://github.com/ckan/ckanext-pages.git
cd ckanext-pages
git checkout b9f7e49db5c036c602b1bff7050e91eccdc00b53
cd ..

git clone --branch 0.10.0 --depth 1 https://github.com/ckan/ckanext-xloader.git

# Not a CKAN extenion, but another Python module used by a CKAN extenion. Install it uneditable.
pip3 install https://github.com/katucker/messytables/archive/refs/heads/ed.zip

git clone --branch master https://github.com/datopian/ckanext-dataexplorer-react.git
cd ckanext-dataexplorer-react
git checkout 73173a1e831dd417a7b252826b0e7ec75cf3459c
cd ..

git clone --branch ed-multi-saml --depth 1 https://github.com/datopian/ckanext-saml2auth.git

