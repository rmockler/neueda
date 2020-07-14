#     !/bin/bash
#
#     Task:
#     Create web cluster with two docker containers with a bash script
#     
#     Environment:
#     Docker CE, CentOS 7, HAProxy 1.6, Nginx any version
#     
#     Description:
#     Write a script, which will:
#     1. create and run 2 Docker containers
#     2. installs HAProxy and Nginx in both containers
#     3. configured HAProxy to send traffic to working Nginx servers
#     
#     Acceptance criteria:
#     Solution should be prepared as only one script, which creates two Docker images,
#     run containers from them, configures Nginx and HAProxy,
#     checks Nginxs availability on both containers after start using HAProxy healthchecks.
#     
#     
#     Task:
#     Create web cluster with two docker containers with a bash script
#     
#     Environment:
#     Docker CE, CentOS 7, HAProxy 1.6, Nginx any version
#     
#     Description:
#     Write a script, which will:
#     1. create and run 2 Docker containers
#     2. installs HAProxy and Nginx in both containers
#     3. configured HAProxy to send traffic to working Nginx servers
#     
#     Acceptance criteria:
#     Solution should be prepared as only one script, which creates two Docker images,
#     run containers from them, configures Nginx and HAProxy,
#     checks Nginxs availability on both containers after start using HAProxy healthchecks.
#
#### Prep1 ####
sudo service docker start
#
#### 1. create and run 2 Docker containers
docker run -it -p 81:80 -d centos:7                     
docker run -it -p 82:80 -d centos:7                    
#
#### 2. installs HAProxy and Nginx in both containers
docker ps -aq|sed 's@.*@docker exec -it \0 /bin/bash -c "yum install -y haproxy"@'|tee exec1;source exec1
#
#
#### 3. configured HAProxy to send traffic to working Nginx servers
printf 'defaults\nmode http\noption redispatch\nfrontend http_front\nbind *:80\ndefault_backend http_back\n\nlisten stats\nbind *:89\nstats uri /\nstats realm Haproxy\ Statistics\n\nbackend http_back\nbalance roundrobin\nserver 2p89 172.17.0.2:89 check\nserver 3p89 172.17.0.3:89 check\nserver p81 127.0.0.1:81 check\nserver p82 127.0.0.1:82 check\n' |tee ha.cfg
docker ps -aq|sed 's@.*@docker cp ha.cfg \0:/@'|tee exec1;source exec1
docker ps -aq|sed 's@.*@docker exec -it \0 /bin/bash -c "haproxy -f ha.cfg -D"@'|tee exec1;source exec1
#
#### Testing / Notes ####
