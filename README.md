# nginx with more modules

## 说明
nginx，但是是一个内置更多模块的docker镜像，减少自己编译的时间，不再担心缺少某些模块需要自己来编译。

## 使用

版本号不具有代表性，因为随时会嵌入新的模块，我将只维护比较新的版本，无论如何都请只使用latest标签。

```bash
docker pull murasamezako/nginx-wmm:latest
```

## 自己编译

```bash
git clone https://github.com/murasame-zako/nginx-wmm
cd nginx-wmm
docker build -t nginx-wmm .
```

## 模块和功能概况

|已经嵌入的模块|来源|
|--|--|
|nginx-dav-ext-module|https://github.com/arut/nginx-dav-ext-module|
|nginx-rtmp-module|https://github.com/arut/nginx-rtmp-module
|headers-more-nginx-module|https://github.com/openresty/headers-more-nginx-module
|ngx_http_geoip2_module|https://github.com/leev/ngx_http_geoip2_module
|ngx-fancyindex|https://github.com/aperezdc/ngx-fancyindex
|naxsi|https://github.com/wargio/naxsi

|已经启用的功能|
|--|
|select_module|
|poll_module|
|threads|
|http_ssl_module|
|http_v2_module|
|http_v3_module|
|http_realip_module|
|http_addition_module|
|http_xslt_module|
|http_image_filter_module|
|http_geoip_module|
|http_sub_module|
|http_dav_module|
|http_flv_module|
|http_mp4_module|
|http_gunzip_module|
|http_gzip_static_module|
|http_auth_request_module|
|http_random_index_module|
|http_secure_link_module|
|http_degradation_module|
|http_slice_module|
|http_stub_status_module|
|http_perl_module|
|mail|
|mail_ssl_module|
|stream|
|stream_ssl_module|
|stream_realip_module|
|stream_geoip_module|
|stream_ssl_preread_module|
|compat|
|pcre|
|pcre-jit|