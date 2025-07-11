# ===============================
# Stage 1: Build pgvector
# ===============================
FROM pgduckdb/pgduckdb:17-main AS builder

USER root

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    postgresql-server-dev-17 \
 && rm -rf /var/lib/apt/lists/*

# Clone and build pgvector
RUN git clone --depth=1 --branch v0.8.0 https://github.com/pgvector/pgvector.git /pgvector \
 && cd /pgvector && make

# ===============================
# Stage 2: Final image for Railway
# ===============================
FROM pgduckdb/pgduckdb:17-main

USER root

# Copy the built extension
COPY --from=builder /pgvector/vector.so /usr/lib/postgresql/17/lib/vector.so
COPY --from=builder /pgvector/vector.control /usr/share/postgresql/17/extension/vector.control
COPY --from=builder /pgvector/sql/ /usr/share/postgresql/17/extension/

# Custom init scripts and config
COPY ./init-scripts/ /docker-entrypoint-initdb.d/
COPY ./config/postgresql.conf /etc/postgresql/postgresql.conf

# Set proper permissions
RUN chown -R postgres:postgres \
    /usr/lib/postgresql/17/lib/vector.so \
    /usr/share/postgresql/17/extension/ \
    /docker-entrypoint-initdb.d/ \
    /etc/postgresql/postgresql.conf

USER postgres

