# ---------- Etapa 1: compilar y armar el WAR ----------
FROM tomcat:10.1-jdk21 AS build

WORKDIR /app

# Copiar código fuente y aplicación web
COPY src ./src
COPY web ./web

# Crear carpeta para librerías
RUN mkdir -p web/WEB-INF/lib

# Agregar MySQL Connector/J
ADD https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/26.7.0/mysql-connector-j-26.7.0.jar /app/web/WEB-INF/lib/mysql-connector-j-26.7.0.jar

# Compilar Java y generar WAR
RUN mkdir -p web/WEB-INF/classes \
 && javac -encoding UTF-8 \
      -cp "/usr/local/tomcat/lib/servlet-api.jar:web/WEB-INF/lib/*" \
      -d web/WEB-INF/classes \
      $(find src/java -name "*.java") \
 && cd web \
 && jar cf /app/ROOT.war .

# ---------- Etapa 2: servidor Tomcat ----------
FROM tomcat:10.1-jdk21

# Eliminar aplicaciones por defecto de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copiar nuestra aplicación como aplicación raíz
COPY --from=build /app/ROOT.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
