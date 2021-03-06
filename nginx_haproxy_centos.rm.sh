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
echo https://github.com/rmockler/neueda
#### Prep1 ####
sudo service docker start
#
#### 1. create and run 2 Docker containers
docker run -it -p 81:80 -d centos:7                     
docker run -it -p 82:80 -d centos:7                    
#
#### 2. installs HAProxy and Nginx in both containers
docker ps -q|sed 's@.*@docker exec -it \0 /bin/bash -c "yum install -y haproxy"@'|tee exec1;source exec1
docker ps -q|sed 's@.*@docker exec -it \0 /bin/bash -c "yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"@'|tee exec1;source exec1
docker ps -q|sed 's@.*@docker exec -it \0 /bin/bash -c "yum install -y nginx"@'|tee exec1;source exec1
#
#
#### 3. configured HAProxy to send traffic to working Nginx servers
printf 'defaults\nmode http\noption redispatch\nfrontend http_front\nbind *:80\ndefault_backend http_back\n\nlisten stats\nbind *:89\nstats uri /\nstats realm Haproxy\ Statistics\n\nbackend http_back\nbalance roundrobin\nserver nginx.172.17.0.2:81 172.17.0.2:81 check\nserver haproxy.172.17.0.2:89 172.17.0.2:89 check\nserver nginx.172.17.0.3:81 172.17.0.3:81 check\nserver haproxy.172.17.0.3:89 172.17.0.3:89 check\n' |tee ha.cfg
docker inspect --format='docker exec -it {{.Config.Hostname}} /bin/bash -c "mv /usr/share/nginx/html/index.html /usr/share/nginx/html/index.`date +%d%h%y%H%00`html;echo \<h1\>Nginx {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}\</h1\>F5 to refresh >> /usr/share/nginx/html/index.html"' $(docker ps -aq)|tee exec1 ;source exec1
printf 'defaults\nmode http\noption redispatch\nfrontend http_front\nbind *:80\ndefault_backend http_back\n\nlisten stats\nbind *:89\nstats uri /\nstats realm Haproxy\ Statistics\n\nbackend http_back\nbalance roundrobin\nserver nginx.172.17.0.2:81 172.17.0.2:81 check\nserver nginx.172.17.0.3:81 172.17.0.3:81 check\n\n' |tee ha.cfg
docker ps -aq|sed 's@.*@docker cp ha.cfg \0:/@'|tee exec1;source exec1
docker ps -aq|sed 's@.*@docker exec -it \0 /bin/bash -c "haproxy -f ha.cfg -D"@'|tee exec1;source exec1
#docker inspect --format='docker exec -it {{.Config.Hostname}} /bin/bash -c "rm /usr/share/nginx/html/index.html;echo \<h1\>{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}\</h1\> >> /usr/share/nginx/html/index.html"' $(docker ps -aq)|tee exec1 ; source exec1
docker ps -aq|sed 's@.*@docker exec -it \0 /bin/bash -c "sed '\''s^80 default^81 default^'\'' /etc/nginx/nginx.conf -i;nginx"@'|tee exec1;source exec1 
#
#
#### Testing / Notes ####
#read -t10 -p " Opening live demo or ctrl-c to escape."
#echo firefox http://52.214.204.249:81/ http://52.214.204.249:82/ https://github.com/rmockler/neueda
printf "\n"
printf "\t\t   Testing and assumptions   \n\n"  
printf "\t\t   Known issues:    \n"  
printf "\t\t   HAProxy has warnings as the defaults are missing.\n"  
printf "\t\t   epel-release not installing for i686 cluster. bug apparantly.\n"  
printf "\t\t   Centos7 systemd components are not all present in this image.\n"  
printf "\t\t   \n"  
printf "\t\t   Further impovements:    \n"  
printf "\t\t   Script as is, is fully functional, but warning could be removed by adding the defaults.\n"  
printf "\t\t   It is unlikely that this will be run on anything except x86_64, but if required, a case statement could manually install epel by rpm.\n"  
printf "\t\t   There is a a centos:systemd image but out-of-scope.\n"  
printf "\n"




