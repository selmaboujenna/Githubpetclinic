FROM registry.access.redhat.com/ubi8/ubi

RUN curl -O https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.88/bin/apache-tomcat-9.0.88.tar.gz

RUN tar xvf apache-tomcat-9.0.88.tar.gz

RUN yum install -y java-11

COPY /target/petclinic.war /apache-tomcat-9.0.88/webapps

EXPOSE 8080

CMD ["apache-tomcat-9.0.88/bin/catalina.sh", "run"]
