# Build stage
FROM maven:3.9.9-eclipse-temurin-21 AS builder

WORKDIR /build

# cache de dependências
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .

RUN chmod +x mvnw

# baixa dependências antes
RUN ./mvnw dependency:go-offline

# copia source
COPY src src

# build
RUN ./mvnw clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre

WORKDIR /app

COPY --from=builder /build/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]