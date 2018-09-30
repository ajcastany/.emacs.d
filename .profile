export WORKON_HOME=$HOME/.pyenv/versions
export PROJECT_HOME=$HOME/Code/python
export PYENV_ROOT="${HOME}/.pyenv"

if [ -d "${PYENV_ROOT}" ]; then
    export PATH="${PYENV_ROOT}/bin:${PATH}"
    eval "$(pyenv init -)"
fi

#Keep the following line commented.
pyenv virtualenvwrapper_lazy #Uncomment this line for initial configuration.
