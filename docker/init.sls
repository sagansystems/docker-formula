docker:
    pkg:
        - installed

python-docker-py:
    pkg:
        - installed

docker.service.enabled:
    service.enabled:
        - name: docker
        - require:
            - pkg: docker

docker.upgrade:
    cmd:
        - run
        - name: wget -q https://get.docker.com/builds/Linux/x86_64/docker-{{ pillar['docker']['version'] }} -O /usr/bin/docker
        - unless: docker -v | grep {{ pillar['docker']['version'] }}
        - require:
          - pkg: wget

docker.service.running:
    service.running:
        - name: docker
        - enable: True
        - watch:
            - cmd: docker.upgrade

docker.service.dead:
    service.dead:
        - name: docker
        - prereq:
            - cmd: docker.upgrade

tutum/tomcat:
    docker.pulled:
        - tag: 7.0
        - require:
            - pkg: python-docker-py
            - cmd: docker.upgrade
            - service: docker.service.running

vagrant:
    user.present:
        - groups:
            - docker
        - require:
            - pkg: docker

docker.socket.permission:
    module.run:
        - name: file.chgrp
        - path: /var/run/docker.sock
        - group: docker
        - requires: docker

fig:
    cmd:
        - run
        - name: |
            wget -q https://github.com/docker/fig/releases/download/{{ pillar['docker']['fig_version'] }}/fig-`uname -s`-`uname -m` -O /usr/local/bin/fig
            chmod +x /usr/local/bin/fig
        - unless: /usr/local/bin/fig --version | grep {{ pillar['docker']['fig_version'] }}
        - require:
          - pkg: wget
