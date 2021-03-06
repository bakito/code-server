#!/bin/bash

CONF_FILE=/etc/cntlm.conf

if [ -z "${CNTLM_PROXY}" ]; then
  echo "ERROR: please provide the CNTLM_PROXY"
  exit 1
fi

echo "Proxy    ${CNTLM_PROXY}" > ${CONF_FILE}

if [ -z "${CNTLM_NO_PROXY}" ]; then
  echo "ERROR: please provide the CNTLM_NO_PROXY"
  exit 1
fi

echo "NoProxy    ${CNTLM_NO_PROXY}" >> ${CONF_FILE}

echo "Gateway    yes" >> ${CONF_FILE}
echo "Listen     0.0.0.0:3128" >> ${CONF_FILE}

if [ -z "${CNTLM_USERNAME}" ]; then
  echo "ERROR: please provide the CNTLM_USERNAME"
  exit 1
fi

echo "Username    ${CNTLM_USERNAME}" >> ${CONF_FILE}

if [ -z "${CNTLM_DOMAIN}" ]; then
  echo "ERROR: please provide the CNTLM_DOMAIN"
  exit 1
fi

echo "Domain      ${CNTLM_DOMAIN}" >> ${CONF_FILE}

if [ "${CNTLM_VERBOSE}" == "true" ]; then
  RUN_VERBOSE=-v
else
  RUN_VERBOSE=
fi

cntlm ${RUN_VERBOSE} -I