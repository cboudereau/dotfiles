@echo off
set rp=%cd:~3%
set rp=/mnt/c/%rp:\=/%

bash -c "cd %rp% && docker compose "%*