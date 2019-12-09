# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions


if ! whoami &>/dev/null; then
  if [ -w /etc/passwd ]; then
    echo "coder:x:$(id -u):$(id -g):coder user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi

source <(oc completion bash)

export PS1="\[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "

. ~/.gimme/envs/latest.env 2>&1

alias l.='ls -d .* --color=auto'
alias ll='ls -lh --color=auto'
alias ls='ls --color=auto'
