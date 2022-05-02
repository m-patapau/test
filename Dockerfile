# Builder image
FROM eclipse-temurin:17-alpine as builder

# Choose workdir
WORKDIR application

# Copy JAR file
COPY build/libs/*jar ./app.jar

# Extract layers from JAR
RUN java -Djarmode=layertools -jar app.jar extract

# Use slim image. For java 17 we can use Jlink to create JRE
FROM eclipse-temurin:17-alpine

# Add curl to container
RUN apk --no-cache add curl

# Setup user
RUN addgroup -S thg-freight && adduser -S thg-freight -G thg-freight \
  && mkdir /application && chown thg-freight:thg-freight /application
USER thg-freight:thg-freight

# Choose workdir
WORKDIR application

# Copy layers of fatjar to use all benifits of cache
COPY --from=builder /application/dependencies/ .
COPY --from=builder /application/spring-boot-loader/ .
COPY --from=builder /application/snapshot-dependencies/ .
COPY --from=builder /application/application/ .

ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
