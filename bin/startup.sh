#!/bin/bash

INSTALL=/home/coder-install

if [[ ! -f /home/coder/.setup-done ]];then
  echo "Preparing initial env ..."
  cp -Rf ${INSTALL}/.bashrc ${HOME}
  cp -Rf ${INSTALL}/.cache ${HOME}
  cp -Rf ${INSTALL}/.gimme ${HOME}
  cp -Rf ${INSTALL}/.local ${HOME}
  cp -Rf ${INSTALL}/workspace ${HOME}
  echo "... done"
  touch /home/coder/.setup-done
fi

if [[ -d /home/coder-install/extensions ]]; then
  for ex in $(find /home/coder-install/extensions -type d); do # Not recommended, will break on whitespace
    if [[ -f /home/coder-install/extensions/${ex}/setup.sh ]]; then
      echo "Perparing extension ${ex} ..."
      bash /home/coder-install/extensions/${ex}/setup.sh
      echo "... done"
    fi
  done
fi

. ~/.gimme/envs/latest.env 2>&1

code-server ${HOME}/workspace
