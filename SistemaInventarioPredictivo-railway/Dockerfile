# ---------- Etapa 1: compilar y armar el WAR ----------
FROM tomcat:10.1-jdk21 AS build
WORKDIR /app
COPY src ./src
COPY web ./web

# Driver JDBC de SQL Server dentro del WAR
ADD https://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/12.8.1.jre11/mssql-jdbc-12.8.1.jre11.jar web/WEB-INF/lib/mssql-jdbc.jar

RUN mkdir -p web/WEB-INF/classes \
 && javac -encoding UTF-8 \
      -cp /usr/local/tomcat/lib/servlet-api.jar \
      -d web/WEB-INF/classes \
      $(find src/java -name "*.java") \
 && cd web && jar cf /app/ROOT.war .

# ---------- Etapa 2: servidor ----------
FROM tomcat:10.1-jdk21
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/ROOT.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
