# ---- Builder stage ----
FROM gradle:8.10.2-jdk21 AS builder

WORKDIR /app

# Copy Gradle wrapper files first (important for caching)
COPY gradle/ ./gradle/
COPY gradlew gradlew.bat settings.gradle* build.gradle* ./

# Download dependencies (this layer will be cached if build files don't change)
RUN gradle --no-daemon dependencies --refresh-dependencies || true

# Copy source code (this invalidates cache when code changes)
COPY src ./src

# Build the application without running tests
RUN gradle --no-daemon clean build -x test

# ---- Runtime stage ----
FROM eclipse-temurin:21-jre
WORKDIR /app

# Copy the built JAR from Gradle output (build/libs)
COPY --from=builder /app/build/libs/*.jar /app/app.jar

EXPOSE 4002
ENTRYPOINT ["java", "-jar", "/app/app.jar"]