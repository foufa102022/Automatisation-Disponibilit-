FROM openjdk:17-jdk-alpine
WORKDIR /app
EXPOSE 8888
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]