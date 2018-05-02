#!/bin/bash

# Import our environment variables from systemd
for e in $(tr "\000" "\n" < /proc/1/environ); do
    eval "export $e"
done

# create salt minion keys from docker secrets
if [ -f /run/secrets/minion.pem ] && [ -f /run/secrets/minion.pub ] && [ -f /run/secrets/master.pub ]
then
    echo "=> Overwriting minion public & private key from docker secrets"
    mkdir -p "/etc/salt/pki/minion"
    chmod 700 "/etc/salt/pki/minion"
    cp /run/secrets/minion.pem "/etc/salt/pki/minion/minion.pem"
    cp /run/secrets/minion.pub "/etc/salt/pki/minion/minion.pub"
    cp /run/secrets/master.pub "/etc/salt/pki/minion/minion_master.pub"
fi

BEFORE_EXEC_SCRIPT=${BEFORE_EXEC_SCRIPT:-/etc/salt/before-exec.sh}
if [ -x "$BEFORE_EXEC_SCRIPT" ]
then
    echo "=> Running BEFORE_EXEC_SCRIPT [$BEFORE_EXEC_SCRIPT]..."
    $BEFORE_EXEC_SCRIPT
    if [ $? -ne 0 ]
    then
        abort "=> BEFORE_EXEC_SCRIPT [$BEFORE_EXEC_SCRIPT] has failed."
    fi
fi
