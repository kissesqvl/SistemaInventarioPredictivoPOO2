# ---------- Etapa 1: compilar y armar el WAR ----------
FROM tomcat:10.1-jdk21 AS build

WORKDIR /app

# Copiar código fuente y aplicación web
COPY src ./src
COPY web ./web

# Crear carpeta de clases y compilar Java.
# Incluimos las librerías de WEB-INF/lib en el classpath.
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
