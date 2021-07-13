FROM centos

RUN yum install httpd -y
ADD Configs/httpd.conf /etc/httpd/conf/
ADD Website/webapp.html /var/www/html/index.html

CMD /usr/sbin/httpd -DFOREGROUND

EXPOSE 80
