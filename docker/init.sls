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

{% if pillar['docker']['images'] is defined %}
    {% for image, tag in pillar.get('docker', {}).get('images').items() %}
{{ image }}:
    docker.pulled:
        - tag: {{ tag }}
        - require:
            - pkg: python-docker-py
            - cmd: docker.upgrade
            - service: docker.service.running
    {% endfor %}
{% endif %}

{% for user in pillar['docker']['users'] %}
{{ user }}:
    user.present:
        - groups:
            - docker
        - require:
            - pkg: docker
{% endfor %}

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
