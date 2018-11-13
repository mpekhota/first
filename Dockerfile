FROM tomcat:latest
ARG version=1.0.14
RUN wget http://192.168.56.10:8081/nexus/service/local/repositories/snapshots/content/test/${version}/first.war
RUN mv first.war webapps
CMD ["catalina.sh", "run"]
EXPOSE 8088
