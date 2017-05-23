#!/bin/bash

set -m

# create salt minion keys from env variables
if [ -n "${KEY_MINION_PRIV}" ]; then
    if [ -z "${KEY_MINION_PUB}" ] || [ -z "${KEY_MASTER_PUB}" ]; then
        abort "=> All KEY_MINION_PRIV, KEY_MINION_PUB, KEY_MASTER_PUB should be set."
    fi
    echo "=> Overwriting minion public & private key from env variables"
    mkdir -p "${SALT_CONFIG}/pki/minion"
    chmod 700 "${SALT_CONFIG}/pki/minion"
    echo -e "${KEY_MINION_PRIV}" > "${SALT_CONFIG}/pki/minion/minion.pem"
    echo -e "${KEY_MINION_PUB}" > "${SALT_CONFIG}/pki/minion/minion.pub"
    echo -e "${KEY_MASTER_PUB}" > "${SALT_CONFIG}/pki/minion/minion_master.pub"
fi

# create salt minion keys from docker secrets
if [ -f /run/secrets/minion.pem ] && [ -f /run/secrets/minion.pub ] && [ -f /run/secrets/master.pub ]
then
    echo "=> Overwriting minion public & private key from docker secrets"
    mkdir -p "${SALT_CONFIG}/pki/minion"
    chmod 700 "${SALT_CONFIG}/pki/minion"
    cp /run/secrets/minion.pem "${SALT_CONFIG}/pki/minion/minion.pem"
    cp /run/secrets/minion.pub "${SALT_CONFIG}/pki/minion/minion.pub"
    cp /run/secrets/master.pub "${SALT_CONFIG}/pki/minion/minion_master.pub"
fi

if [ -x "$BEFORE_EXEC_SCRIPT" ]
then
    echo "=> Running BEFORE_EXEC_SCRIPT [$BEFORE_EXEC_SCRIPT]..."
    $BEFORE_EXEC_SCRIPT
    if [ $? -ne 0 ]
    then
        abort "=> BEFORE_EXEC_SCRIPT [$BEFORE_EXEC_SCRIPT] has failed."
    fi
fi

echo "=> Running EXEC_CMD [$EXEC_CMD]..."
exec $EXEC_CMD
