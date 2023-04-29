# build stage
FROM rust:latest as builder
WORKDIR /usr/src/ai-services
COPY . .
RUN cargo build --release

# runtime stage
FROM debian:buster-slim
# Install the libssl package
RUN apt-get update && apt-get install -y libssl-dev ca-certificates

# Update the library path
RUN echo "/usr/local/lib" | tee /etc/ld.so.conf.d/usr-local.conf && ldconfig

# Update the SSL certificate store
RUN update-ca-certificates

COPY --from=builder /usr/src/ai-services/target/release/ai-services /usr/local/bin/ai-services

# Copy the 'ui' directory from the builder stage to the runtime image
COPY --from=builder /usr/src/ai-services/ui /usr/src/ai-services/ui

# Set the working directory to the location of the 'ui' folder
WORKDIR /usr/src/ai-services

CMD ["ai-services"]
