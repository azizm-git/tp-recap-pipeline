FROM eclipse-temurin:11-jre-alpine
COPY target/helloworld-1.0.jar /app.jar
CMD ["java", "-jar", "/app.jar"]
