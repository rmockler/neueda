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
tag6=hapilot
ips6=65081
export number_of_containers=2
read -t 10 -p "Redeploy cluster size (default 2): " number_of_containers
NOC=$(($ips6 + $number_of_containers))
echo "NOC=$NOC" ; sleep 5
#
#### 1. create and run 2 Docker containers
docker stop $(docker ps -a|grep $tag6|cut -d ' ' -f1)
docker rm   $(docker ps -a|grep $tag6|cut -d ' ' -f1)  # merge these later

for ((i=$NOC;i>=$ips6;i--)); 
  do 
  docker run -it --name rm$i$tag6 -p $i:80 -d centos:7                     
  done
docker ps -a|grep $tag6
#read -t60 -p 'ctrl-c to exit'
#
#### 2. installs HAProxy and Nginx in both containers
docker ps -aq|sed 's@.*@docker exec -it \0 /bin/bash -c "yum install -y haproxy"@'|tee exec1;source exec1
#
#
#### 3. configured HAProxy to send traffic to working Nginx servers
printf 'defaults\nmode http\noption redispatch\nfrontend http_front\nbind *:80\ndefault_backend http_back\n\nlisten stats\nbind *:89\nstats uri /\nstats realm Haproxy\ Statistics\n\nbackend http_back\nbalance roundrobin\n' |tee ha1.cfg
docker inspect --format='server app_{{.Config.Hostname}} {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}:89 check' $(docker ps -aq) |tee ha2.cfg
cat ha1.cfg ha2.cfg > ha.cfg
#printf '\nserver container1 172.17.0.1 check\nserver container2 172.17.03:6082 check\n' |tee -a ha.cfg
docker ps -aq|sed 's@.*@docker cp ha.cfg \0:/@'|tee exec1;source exec1
docker ps -aq|sed 's@.*@docker exec -it \0 /bin/bash -c "haproxy -f ha.cfg -D"@'|tee exec1;source exec1
#
#### Testing / Notes ####
