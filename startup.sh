#!/bin/bash

INSTALL=/home/coder-install

if [[ ! -f /home/coder/.setup-done ]];then
  echo "Preparing initial env ..."
  mkdir /home/coder/h
  cp -Rf ${INSTALL}/.bashrc ${HOME}
  cp -Rf ${INSTALL}/.cache ${HOME}
  cp -Rf ${INSTALL}/.gimme ${HOME}
  cp -Rf ${INSTALL}/.local ${HOME}
  cp -Rf ${INSTALL}/workspace ${HOME}
  echo "... done"

fi

code-server home/coder/h/workspace