FROM majid7221/debian:stretch

RUN set -ex \
    && groupadd -r mysql \
    && useradd -r -g mysql mysql

RUN mkdir /docker-entrypoint-initdb.d

ENV GPG_KEY 0xF1656F24C74CD1D8
ENV MARIADB_MAJOR 10.4

RUN set -ex \
    && apt-key adv --no-tty --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 $GPG_KEY \
    && echo "deb http://ftp.osuosl.org/pub/mariadb/repo/$MARIADB_MAJOR/debian stretch main" > /etc/apt/sources.list.d/mariadb.list \
	&& { \
		echo 'Package: *'; \
		echo 'Pin: release o=MariaDB'; \
		echo 'Pin-Priority: 999'; \
       } > /etc/apt/preferences.d/mariadb \
    && { \
		echo "mariadb-server-$MARIADB_MAJOR" mysql-server/root_password password '123456'; \
		echo "mariadb-server-$MARIADB_MAJOR" mysql-server/root_password_again password '123456'; \
       } | debconf-set-selections \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
		mariadb-server \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/* \
    # comment out any "user" entires in the MySQL config ("docker-entrypoint.sh" or "--user" will handle user switching)
    && sed -ri 's/^user\s/#&/' /etc/mysql/my.cnf /etc/mysql/conf.d/* \
    # purge and re-create /var/lib/mysql with appropriate ownership
	&& rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld \
	&& chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
    # ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
	&& chmod 777 /var/run/mysqld \
    # comment out a few problematic configuration values
	&& find /etc/mysql/ -name '*.cnf' -print0 \
		| xargs -0 grep -lZE '^(bind-address|log)' \
		| xargs -rt -0 sed -Ei 's/^(bind-address|log)/#&/' \
    # don't reverse lookup hostnames, they are usually another container
    && echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf

VOLUME ["/var/lib/mysql"]

COPY docker-entrypoint.sh /usr/local/bin/

# backwards compat
RUN ln -s usr/local/bin/docker-entrypoint.sh /

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
