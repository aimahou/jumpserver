FROM centos:latest
LABEL maintainer "wojiushixiaobai"
WORKDIR /opt

ENV LUNA_VER=1.4.10

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && yum -y install kde-l10n-Chinese \
    && yum -y reinstall glibc-common \
    && localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 \
    && export LC_ALL=zh_CN.UTF-8 \
    && echo 'LANG="zh_CN.UTF-8"' > /etc/locale.conf \
    && yum -y install wget gcc epel-release git yum-utils \
    && yum -y install python36 python36-devel \
    && echo -e "[nginx-stable]\nname=nginx stable repo\nbaseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/\ngpgcheck=1\nenabled=1\ngpgkey=https://nginx.org/keys/nginx_signing.key" > /etc/yum.repos.d/nginx.repo \
    && rpm --import https://nginx.org/keys/nginx_signing.key \
    && yum -y install mariadb mariadb-devel mariadb-server redis nginx \
    && rm -rf /etc/nginx/conf.d/default.conf \
    && yum clean all \
    && rm -rf /var/cache/yum/*

RUN set -ex \
    && git clone --depth=1 https://github.com/jumpserver/jumpserver.git \
    && wget https://demo.jumpserver.org/download/luna/${LUNA_VER}/luna.tar.gz \
    && tar xf luna.tar.gz \
    && chown -R root:root luna \
    && yum -y install $(cat /opt/jumpserver/requirements/rpm_requirements.txt) \
    && python3.6 -m venv /opt/py3 \
    && source /opt/py3/bin/activate \
    && pip install --upgrade pip setuptools \
    && pip install -r /opt/jumpserver/requirements/requirements.txt \
    && curl -o /etc/nginx/conf.d/jumpserver.conf https://demo.jumpserver.org/download/nginx/conf.d/jumpserver.conf \
    && yum clean all \
    && rm -rf /var/cache/yum/* \
    && rm -rf /opt/luna.tar.gz \
    && rm -rf /var/cache/yum/* \
    && rm -rf ~/.cache/pip

COPY readme.txt readme.txt
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

VOLUME /opt/jumpserver/data/media
VOLUME /var/lib/mysql

ENV LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8

ENV SECRET_KEY=kWQdmdCQKjaWlHYpPhkNQDkfaRulM6YnHctsHLlSPs8287o2kW \
    BOOTSTRAP_TOKEN=KXOeyNgDeTdpeu9q

ENV DB_ENGINE=mysql \
    DB_HOST=127.0.0.1 \
    DB_PORT=3306 \
    DB_USER=jumpserver \
    DB_PASSWORD=weakPassword \
    DB_NAME=jumpserver

ENV REDIS_HOST=127.0.0.1 \
    REDIS_PORT=6379 \
    REDIS_PASSWORD=

EXPOSE 80 8080
ENTRYPOINT ["entrypoint.sh"]
