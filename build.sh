#!/bin/bash
set -o errexit
set -o pipefail
set -x

cd /build

apk --no-cache upgrade
apk --no-cache add git gcc g++ make jq pcre-dev openssl-dev zlib-dev perl-dev libxml2-dev libxslt-dev gd-dev geoip-dev

get_user_name() {
	cat /etc/passwd | grep :${1} | cut -d ":" -f 1
}
get_group_name() {
	cat /etc/group | grep ${1}: | cut -d ":" -f 1
}

if [ -z $(get_user_name ${NGINX_UID}) ]; then
	true
else
	deluser $(get_user_name ${NGINX_UID})
fi

if [ -z $(get_group_name ${NGINX_USER}) ]; then
	true
else
	delgroup $(get_group_name ${NGINX_USER})
fi

addgroup -g ${NGINX_UID} -S ${NGINX_USER}
adduser -S -D -H -u ${NGINX_UID} -G ${NGINX_USER} ${NGINX_USER}

libmaxminddb_release=$(wget -qO- -t1 "https://api.github.com/repos/maxmind/libmaxminddb/releases/latest" | jq -r .tag_name)
wget https://github.com/maxmind/libmaxminddb/releases/download/${libmaxminddb_release}/libmaxminddb-${libmaxminddb_release}.tar.gz
tar -xzf libmaxminddb-${libmaxminddb_release}.tar.gz
cd libmaxminddb-${libmaxminddb_release}
bash configure
make -j $(nproc)
make -j $(nproc) install
cd ..

git clone --recursive https://github.com/arut/nginx-dav-ext-module
git clone --recursive https://github.com/arut/nginx-rtmp-module
git clone --recursive https://github.com/openresty/headers-more-nginx-module
git clone --recursive https://github.com/leev/ngx_http_geoip2_module
git clone --recursive https://github.com/aperezdc/ngx-fancyindex

wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar xzf nginx-${NGINX_VERSION}.tar.gz
cd nginx-${NGINX_VERSION}
bash ./configure \
	--prefix=/usr/local/nginx \
	--user=${NGINX_USER} \
	--group=${NGINX_USER} \
	--add-module=../nginx-dav-ext-module \
	--add-module=../nginx-rtmp-module \
	--add-module=../headers-more-nginx-module \
	--add-module=../ngx_http_geoip2_module \
	--add-module=../ngx-fancyindex \
	--with-select_module \
	--with-poll_module \
	--with-threads \
	--with-http_ssl_module \
	--with-http_v2_module \
	--with-http_v3_module \
	--with-http_realip_module \
	--with-http_addition_module \
	--with-http_xslt_module \
	--with-http_image_filter_module \
	--with-http_geoip_module \
	--with-http_sub_module \
	--with-http_dav_module \
	--with-http_flv_module \
	--with-http_mp4_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_auth_request_module \
	--with-http_random_index_module \
	--with-http_secure_link_module \
	--with-http_degradation_module \
	--with-http_slice_module \
	--with-http_stub_status_module \
	--with-http_perl_module \
	--with-mail \
	--with-mail_ssl_module \
	--with-stream \
	--with-stream_ssl_module \
	--with-stream_realip_module \
	--with-stream_geoip_module \
	--with-stream_ssl_preread_module \
	--with-compat \
	--with-pcre \
	--with-pcre-jit \
	--with-cc-opt="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC" \
	--with-ld-opt="-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie"
make -j$(nproc)
make -j$(nproc) install
cd ..

ln -s /usr/local/nginx/sbin/nginx /sbin/nginx
ln -s /usr/local/nginx/conf/ /etc/nginx
ln -s /usr/local/nginx/logs/ /var/log/nginx

ln -s /dev/stdout /usr/local/nginx/logs/access.log
ln -s /dev/stderr /usr/local/nginx/logs/error.log

cp docker-entrypoint.sh /
chmod 777 /docker-entrypoint.sh

cd /
rm -rf /build