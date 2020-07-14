# Neueda
Neueda Project

<h1>Project Scope</h1>
Automation script in bash

<h1>Requirements</h1>
#     1. create and run 2 Docker containers<br>
#     2. installs HAProxy and Nginx in both containers<br>
#     3. configured HAProxy to send traffic to working Nginx servers<br>
<br>
<blockquote>
<h6>Criteria states:</h6>
  <li> Create web cluster with two docker containers with a bash script
  <li> Solution should be prepared as only one script, which creates two Docker images,
  <li> run containers from them, configures Nginx and HAProxy,
  <li> checks Nginxs availability on both containers after start using HAProxy healthchecks.
</blockquote>
It was not asked to show workings but intirm haproxy only version also included:
<p><b>docker_centos_haproxy.rm.sh</b></p>

Working and tested version (submitted 10jul20):
<p><b>docker_centos_haproxy_nginx.rm.sh</b></p>

Live Demo Container 1
http://52.214.204.249:81

Live Demo Container 2
http://52.214.204.249:82



<br>defaults
<br>mode http
<br>option redispatch
<br>frontend http_front
<br>bind *:80
<br>default_backend http_back
<br>
<br>listen stats
<br>bind *:89
<br>stats uri /
<br>stats realm Haproxy\ Statistics
<br>
<br>backend http_back
<br>balance roundrobin
<br>server nginx.172.17.0.2:81 172.17.0.2:81 check
<br>server haproxy.172.17.0.2:89 172.17.0.2:89 check
<br>server nginx.172.17.0.3:81 172.17.0.3:81 check
<br>server haproxy.172.17.0.3:89 172.17.0.3:89 check
