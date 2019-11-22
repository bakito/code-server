FROM ubuntu:19.04

WORKDIR /home/coder

EXPOSE 8080

ENTRYPOINT ["dumb-init", "code-server" , "workspace"]

RUN apt-get update && apt-get install -y \
	openssl \
	net-tools \
	git \
	locales \
	sudo \
	dumb-init \
	vim \
	curl \
	wget \
    bash-completion \
    fzf \
    jq \
    upx


RUN locale-gen en_US.UTF-8
# We unfortunately cannot use update-locale because docker will not use the env variables
# configured in /etc/default/locale so we need to set it manually.
ENV LC_ALL=en_US.UTF-8


ENV CODE_SERVER_VERSION=2.1692-vsc1.39.2

RUN mkdir /tmp/code-server && \
    curl -L https://github.com/cdr/code-server/releases/download/${CODE_SERVER_VERSION}/code-server${CODE_SERVER_VERSION}-linux-x86_64.tar.gz -o /tmp/code-server/code-server.tar.gz && \
    tar xzvf /tmp/code-server/code-server.tar.gz -C /tmp/code-server/ --strip-components 1 && \
    chmod +x /tmp/code-server/code-server && \
    mv /tmp/code-server/code-server /usr/local/bin/code-server && \
    rm -rf /tmp/code-server

# oc
RUN mkdir /tmp/oc && \
    curl -L https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz -o /tmp/oc/oc.tar.gz && \
    tar xzvf /tmp/oc/oc.tar.gz -C /tmp/oc/ --strip-components 1 && \
    chmod +x /tmp/oc/oc && \
    upx /tmp/oc/oc && \
    mv /tmp/oc/oc /usr/local/bin/oc && \
    rm -rf /tmp/oc

# yq
RUN curl -L https://github.com/mikefarah/yq/releases/download/2.4.1/yq_linux_amd64 -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq && \
    upx /usr/local/bin/yq

# helm
RUN curl "https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3" | bash 

# gimme
RUN curl -sL -o /usr/local/bin/gimme https://raw.githubusercontent.com/travis-ci/gimme/master/gimme && \
    chmod +x /usr/local/bin/gimme && \
    upx /usr/local/bin/gimme

## User account
RUN adduser --disabled-password --gecos '' coder && \
    adduser coder sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers;


RUN chmod g+rw /home && \
    mkdir -p /home/coder/workspace && \
    chown -R coder:coder /home/coder && \
    chown -R coder:coder /home/coder/workspace;

USER coder

# helm plugins
RUN helm plugin install https://github.com/helm/helm-2to3 && \
    helm plugin install https://github.com/databus23/helm-diff && \
    helm plugin install https://github.com/bakito/helm-patch

# go
RUN gimme stable

# extensions
RUN EXTENSIONS="ms-vscode.Go \
                eamodio.gitlens \
                humao.rest-client \
                ms-kubernetes-tools.vscode-kubernetes-tools \
                redhat.vscode-openshift-connector \
                redhat.vscode-yaml \
                yzhang.markdown-all-in-one \
                vscode-icons-team.vscode-icons" && \
    for ex in ${EXTENSIONS}; do code-server --install-extension ${ex} --force; done

# settings
COPY --chown=coder:coder settings.json /home/coder/.local/share/code-server/User/

ENV DEFAULT_PASSWORD="P@ssw0rd"
ENV PASSWORD=${PASSWORD:-DEFAULT_PASSWORD}

RUN echo "source <(oc completion bash)" >> /home/coder/.bashrc && \
    echo 'export PS1="\[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> /home/coder/.bashrc && \
    echo '. ~/.gimme/envs/latest.env 2>&1' >> /home/coder/.bashrc 
