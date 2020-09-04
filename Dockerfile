FROM codercom/code-server
ENV HOME=/home/coder
USER root

RUN apt-get update \
    && apt-get install -y make build-essential wget apt-transport-https gnupg \
    && curl https://baltocdn.com/helm/signing.asc | sudo apt-key add - \
    && apt-get update \
    && echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list \
    && apt-get update \
    && apt-get install helm \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

COPY bin/fix-permissions.sh /home/coder/bin/
RUN  chown -R coder /home/coder\ 
    && /home/coder/bin/fix-permissions.sh /home/coder

USER coder

RUN curl -sL -o /home/coder/bin/gimme https://raw.githubusercontent.com/travis-ci/gimme/master/gimme \
    && chmod +x /home/coder/bin/gimme
