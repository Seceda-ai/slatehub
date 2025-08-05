# Stage 1: Build the application
FROM rust:1.78-slim-bullseye AS builder

# Set the working directory
WORKDIR /usr/src/slatehub-api

# Install build dependencies (if any)
# For now, none are needed, but this is where you'd add packages like libpq-dev
# RUN apt-get update && apt-get install -y -qq build-essential

# Create a new empty shell project to cache dependencies
RUN cargo init --bin .

# Copy over the dependency manifests
COPY Cargo.toml Cargo.lock ./

# Build dependencies, this will be cached if the manifests don't change
RUN cargo build --release
RUN rm -f target/release/deps/slatehub_api*

# Copy the actual source code
COPY src ./src

# Build the application
RUN cargo build --release

# Stage 2: Create the final, smaller image
FROM debian:bullseye-slim AS runner

# Set the working directory
WORKDIR /usr/local/bin

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/slatehub-api/target/release/slatehub-api .

# Expose the port the API runs on
EXPOSE 3000

# Set the command to run the application
CMD ["./slatehub-api"]
