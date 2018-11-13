FROM tomcat:latest
ARG version=1.0.15
RUN wget http://192.168.56.10:8081/nexus/service/local/repositories/snapshots/content/test/${version}/first.war
RUN mv first.war webapps
CMD ["catalina.sh", "run"]
<<<<<<< HEAD
EXPOSE 8089
=======
EXPOSE 8089
>>>>>>> 4b2ea9063f67cf70dfbe895dd77a90e3f3e516e6
