docker-salt-minion
==================

Salt-minion docker container (for testing purpose).


Build
-----

To create the image `bbinet/salt-minion`, execute the following command in the
`docker-salt-minion` folder:

    docker build -t bbinet/salt-minion .

You can now push the new image to the public registry:
    
    docker push bbinet/salt-minion


Run
---

Then, when starting your `salt-minion` container, you will want to link it to
the `salt-master` container with the `--link salt-master:salt-master` option.

The `salt-minion` container will read its configuration from the `/etc/salt`
directory volume, so you should bind this config volume to a host directory or
data container. The `salt-minion` will load existing settings for the salt
configuration and pki stuff from this `/etc/salt` volume.

For example:

    $ docker pull bbinet/salt-minion

    $ docker run --name salt-minion \
        -v /home/salt-minion/config:/etc/salt \
        --link salt-master:salt-master
        bbinet/salt-minion
