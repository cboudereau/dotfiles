@echo on
wsl --cd %cd% -e bash -c "docker %*"