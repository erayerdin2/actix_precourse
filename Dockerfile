FROM lukemathwalker/cargo-chef:0.1.67-rust-1.79-alpine3.20 AS chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder 
COPY --from=planner /app/recipe.json recipe.json
# Build dependencies - this is the caching Docker layer!
RUN cargo chef cook --release --recipe-path recipe.json
# Build application
COPY . .
RUN cargo build --release --bin actixblog_precourse

# We do not need the Rust toolchain to run the binary!
FROM alpine:3.20 AS runtime
WORKDIR /app
COPY --from=builder /app/target/release/actixblog_precourse /usr/local/bin
EXPOSE 8080:8080
ENTRYPOINT ["/usr/local/bin/actixblog_precourse"]