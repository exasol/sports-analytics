
# Exasol sports analytics script language container

## Overview

Exasol uses script languages Docker container to execute different programming
languages inside the database. Normaly you have to build this container on your own.
To save time, we provide the pre-build Python3 container with all packages needed
for our sports analytics showcases.

## Prerequisite

* Running Exasol instance or Exasol community edition
* Writing access to BucketFS

If you don't know, how to configure and access BucketFS you can
follow the first and second video of our tutorials:
https://www.exasol.com/portal/display/TRAINING/BucketFS


## Deploying the Python3 sports analytics container

* Download and unzip the container file
* Upload the Python container to the BucketFS by:

1) Using the BucketFS Explorer: https://github.com/exasol/bucketfs-explorer

2) Pushing it via CURL
```bash
$ curl -vX PUT -T pythonclient.tar.gz http://w:writepw@192.168.56.104:2580/py/pythonclient.tar.gz
```

* Inform the SQL compiler about the new language container and execute following statement in a SQL session
```SQL
alter session set script_languages = 'PYTHON=builtin_python R=builtin_r JAVA=builtin_java PY2=localzmq+protobuf:///bfsdefault/default/EXAClusterOS/ScriptLanguages-6.0.0#buckets/bfsdefault/py/pythonclient/python2/client PY3=localzmq+protobuf:///bfsdefault/default/EXAClusterOS/ScriptLanguages-6.0.0#buckets/bfsdefault/py/pythonclient/python3/client';
```

Note: The alter session statements expects the script language container in the Default Bucket of Exasol Community Edition.
This has to be adapted, if you use a different BucketFS.

Note:
If you are using alter session, you need to re-issue the command above when you start a new session.
You could also use alter system to apply the change permanently.

