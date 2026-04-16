FROM openjdk:11-jre-slim
COPY target/helloworld-1.0.jar /app.jar
CMD ["java", "-jar", "/app.jar"]
