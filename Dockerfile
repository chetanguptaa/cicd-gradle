FROM openjdk:11 as base 
WORKDIR /app
COPY . /app
RUN chmod +x gradlew
RUN ./gradlew build

FROM tomcat:9
WORKDIR webapps
COPY --from=base /app/build/lib/WebApp-0.0.1-SNAPSHOT.war .
RUN rm -rf ROOT && mv WebApp-0.0.1-SNAPSHOT.war ROOT.war

