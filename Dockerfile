FROM harbor.chinagci.com/public/euleros:2.5 as build

LABEL author=chenyifu \
      mail=chenyifu@chinagci.com

ENV NGINX_VERSION=1.22.0
ARG CONFIG="\
                --prefix=/usr/local/nginx \
		--user=nginx \
		--group=nginx \
		--with-http_ssl_module \
	   " 

RUN set -x \
&& echo -e '\
[base]\n\
name=EulerOS-2.0SP5 base\n\
baseurl=https://mirrors.huaweicloud.com/euler/2.5/os/x86_64/\n\
enabled=1\n\
gpgkey=https://mirrors.huaweicloud.com/euler/2.5/os/RPM-GPG-KEY-EulerOS\
' >/etc/yum.repos.d/EulerOS.repo \
    && curl -L http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o - |tar -zxf - \
    && yum makecache fast \
    && yum -y install make gcc gcc-c++ zlib zlib-devel openssl openssl-devel pcre pcre-devel
WORKDIR ${HOME}/nginx-${NGINX_VERSION}
RUN set -x \
    && ./configure $CONFIG \
    && make && make install

FROM harbor.chinagci.com/public/euleros:2.5
ENV NGINX_HOME=/usr/local/nginx
ENV PATH="$NGINX_HOME/sbin:$PATH"
RUN set -x \
    && groupadd --gid 101 --system nginx \
    && useradd --uid 101 --shell=/sbin/nologin --no-create-home --system --groups nginx --gid nginx nginx
COPY --from=build /usr/local/nginx /usr/local/nginx
EXPOSE 80
CMD ["nginx","-g","daemon off;"]
