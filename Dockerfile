FROM alpine:latest
ADD * /build
ENV NGINX_VERSION="1.28.0"
ENV NGINX_USER=www-data
ENV NGINX_UID=33
RUN \
	apk --no-cache upgrade && \
	apk --no-cache add bash && \
	bash /build/build.sh
STOPSIGNAL SIGQUIT
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]