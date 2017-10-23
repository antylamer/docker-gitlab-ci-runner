#! /bin/sh
if [ -d "/home/gitlab_ci_multi_runner/ssh-keys" ]; 
then    
	cp /home/gitlab_ci_multi_runner/ssh-keys/* /home/gitlab_ci_multi_runner/.ssh/fish /sbin/entrypoint.sh
fi
entrypoint