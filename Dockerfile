FROM centos:7

# RUN yum update -y
RUN rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm \
    && yum install -y \
        epel-release \
        nginx \
        git

RUN git clone https://github.com/daneden/animate.css.git \
    && cd animate.css \
    && git checkout gh-pages \
    && rm -rf /animate.css/.git \
    && mkdir -p /data \
    && cd / \
    && mv /animate.css /data/www

RUN yum remove -y git \
    && yum clean all

RUN curl -L -s https://install.direct/go.sh | bash -s


COPY conf /conf

COPY run.sh /run.sh
RUN chmod 744 /run.sh

EXPOSE 443

ENTRYPOINT "/run.sh"
