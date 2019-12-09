FROM registry.access.redhat.com/ubi8/ubi

EXPOSE 8080

ENTRYPOINT ["dumb-init", "startup.sh"]

RUN yum install -y  --setopt=tsflags=nodocs \
        openssl \
        net-tools \
        git \
        vim \
        nano \
        curl \
        wget \
        gcc \
        xz \
        procps-ng \
        nodejs && \
    yum clean all

COPY bin/fix-permissions.sh /usr/local/bin/

WORKDIR /home/coder-install
ENV HOME /home/coder-install

ENV CODE_SERVER_VERSION=2.1692-vsc1.39.2

RUN mkdir /tmp/code-server && \
    curl -L https://github.com/cdr/code-server/releases/download/${CODE_SERVER_VERSION}/code-server${CODE_SERVER_VERSION}-linux-x86_64.tar.gz -o /tmp/code-server/code-server.tar.gz && \
    tar xzvf /tmp/code-server/code-server.tar.gz -C /tmp/code-server/ --strip-components 1 && \
    chmod +x /tmp/code-server/code-server && \
    mv /tmp/code-server/code-server /usr/local/bin/code-server && \
    rm -rf /tmp/code-server && \
    fix-permissions.sh /usr/local/bin/code-server

# upx
RUN mkdir /tmp/upx && \
    curl -L https://github.com/upx/upx/releases/download/v3.95/upx-3.95-amd64_linux.tar.xz -o /tmp/upx/upx.tar.xz && \
    tar xJf /tmp/upx/upx.tar.xz -C /tmp/upx/ --strip-components 1 && \
    chmod +x /tmp/upx/upx && \
    mv /tmp/upx/upx /usr/local/bin/upx && \
    rm -rf /tmp/upx && \
    fix-permissions.sh /usr/local/bin/upx

# dumb-init
RUN curl -L https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 -o /usr/local/bin/dumb-init && \
    chmod +x /usr/local/bin/dumb-init && \
    upx /usr/local/bin/dumb-init && \
    fix-permissions.sh /usr/local/bin/dumb-init

# oc
RUN mkdir /tmp/oc && \
    curl -L https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz -o /tmp/oc/oc.tar.gz && \
    tar xzvf /tmp/oc/oc.tar.gz -C /tmp/oc/ --strip-components 1 && \
    chmod +x /tmp/oc/oc && \
    upx /tmp/oc/oc && \
    mv /tmp/oc/oc /usr/local/bin/oc && \
    rm -rf /tmp/oc && \
    fix-permissions.sh /usr/local/bin/oc


# jq
RUN curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o /usr/local/bin/jq && \
    chmod +x /usr/local/bin/jq && \
    upx /usr/local/bin/jq && \
    fix-permissions.sh /usr/local/bin/jq

# yq
RUN curl -L https://github.com/mikefarah/yq/releases/download/2.4.1/yq_linux_amd64 -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq && \
    upx /usr/local/bin/yq && \
    fix-permissions.sh /usr/local/bin/yq

# helm
RUN curl "https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3" | bash 

# gimme
RUN curl -sL -o /usr/local/bin/gimme https://raw.githubusercontent.com/travis-ci/gimme/master/gimme && \
    chmod +x /usr/local/bin/gimme && \
    upx /usr/local/bin/gimme && \
    fix-permissions.sh /usr/local/bin/gimme

RUN chmod g+rw /home && \
    mkdir -p ${HOME}/workspace && \
    mkdir -p ${HOME}/.cache/helm && \
    mkdir -p ${HOME}/.gimme && \
    mkdir -p ${HOME}/.local/share/helm && \
    mkdir -p ${HOME}/.local/share/code-server/User/  && \
    mkdir -p ${HOME}/.local/share/code-server/extensions/  && \
    mkdir -p ${HOME}/.local/share/code-server/logs/  && \
    mkdir -p ${HOME}/.local/share/code-server/machineid/  && \
    fix-permissions.sh ${HOME}/

# helm plugins
RUN helm plugin install https://github.com/helm/helm-2to3 && \
    helm plugin install https://github.com/databus23/helm-diff && \
    helm plugin install https://github.com/bakito/helm-patch && \
    fix-permissions.sh ${HOME}/.cache/helm && \
    fix-permissions.sh ${HOME}/.local/share/helm

# go
RUN gimme stable && \
    fix-permissions.sh ${HOME}/.gimme

# cntlm
RUN curl -L  https://sourceforge.net/projects/cntlm/files/cntlm/cntlm%200.92.3/cntlm-0.92.3-1.x86_64.rpm/download -o /tmp/cntlm.rpm && \
    rpm -ihv /tmp/cntlm.rpm && \
    rm -Rf /tmp/cntlm.rpm && \
    fix-permissions.sh /etc/cntlm.conf

COPY bin/run-cntlm.sh /usr/local/bin/

# settings
COPY settings.json ${HOME}/.local/share/code-server/User/

# extensions
RUN EXTENSIONS="ms-vscode.Go \
                eamodio.gitlens \
                humao.rest-client \
                ms-kubernetes-tools.vscode-kubernetes-tools \
                redhat.vscode-yaml \
                redhat.vscode-openshift-connector \
                yzhang.markdown-all-in-one \
                vscode-icons-team.vscode-icons" && \
    for ex in ${EXTENSIONS}; do code-server --install-extension ${ex} --force; done && \
    cd ${HOME}/.local/share/code-server/extensions/ms-vscode.go-* && npm install && \
    fix-permissions.sh ${HOME}/.local/share/code-server/


ENV DEFAULT_PASSWORD="P@ssw0rd"
ENV PASSWORD=${PASSWORD:-DEFAULT_PASSWORD}

RUN echo "source <(oc completion bash)" >> ${HOME}/.bashrc && \
    echo 'export PS1="\[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> ${HOME}/.bashrc && \
    echo '. ~/.gimme/envs/latest.env 2>&1' >> ${HOME}/.bashrc && \
    fix-permissions.sh ${HOME}/.bashrc && \
    mkdir -p /home/coder && \
    fix-permissions.sh /home/coder && \
    chmod g+rw /etc/passwd
    
COPY bin/startup.sh /usr/local/bin/

WORKDIR /home/coder
ENV HOME /home/coder

USER 1001
