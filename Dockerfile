FROM nareshmahato077/alpine-python3:latest
 
ARG env_project_name
 
ENV  project_name=$env_project_name
COPY ${project_name}.zip /root/${project_name}.zip
 
RUN cd && \
   echo ${project_name} && \
   unzip ${project_name}.zip && \
   cp -r ${project_name} /var/www/ && \
   pip3 install -r requirements.txt && \
   ls -la /var/www && \
   rm -rf /root/${repository_name} /root/${project_name}.zip


# Installing the package
RUN apk add --update \
 python \
 curl \
 which \
 bash
 
RUN echo -e "import os\n\
import sys\n\
path='/var/www/${project_name}'\n\
if path not in sys.path:\n\
    sys.path.append(path)\n\
os.environ['DJANGO_SETTINGS_MODULE'] = '${project_name}.settings'\n\
from django.core.wsgi import get_wsgi_application\n\
application = get_wsgi_application()" >> /var/www/${project_name}/django.wsgi;\
sed -i -r 's@#(LoadModule rewrite_module modules/mod_rewrite.so)@\1@i' /etc/apache2/httpd.conf;\
sed -i -r 's@Errorlog .*@Errorlog /var/log/apache2/error.log@i' /etc/apache2/httpd.conf;\
sed -i -r 's@#Servername .*@ServerName localhost@i' /etc/apache2/httpd.conf;\
sed -i -r 's@Listen 80.*@Listen 8080@i' /etc/apache2/httpd.conf;\
sed -i "s@DocumentRoot \"/var/www/localhost/htdocs\".*@DocumentRoot \"/var/www/${project_name}\"@i" /etc/apache2/httpd.conf;\
sed -i "s@Timeout 300@Timeout 3600@" /etc/apache2/httpd.conf;\
sed -i "s@KeepAliveTimeout 5@KeepAliveTimeout 65@" /etc/apache2/httpd.conf;\
sed -i "s@Group apache@Group root@" /etc/apache2/httpd.conf
 
RUN echo -e "Transferlog /dev/stdout\n\
LoadModule wsgi_module modules/mod_wsgi.so\n\
WSGIPythonPath /usr/lib/python3.6\n\
WSGIScriptAlias / /var/www/${project_name}/django.wsgi\n\
WSGIApplicationGroup %{GLOBAL}\n\
WSGIPassAuthorization On\n\
LimitRequestFieldSize 1048576\n\
<Directory /var/www/${project_name}>\n\
    Options ExecCGI Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
    <Files django.wsgi>\n\
       Require all granted\n\
    </Files>\n\
</Directory>" >> /etc/apache2/httpd.conf
 
 
EXPOSE 8080
CMD ["httpd-foreground"]


