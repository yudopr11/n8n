# pgduckdb with pg_vector Docker Setup

This Docker Compose configuration sets up a PostgreSQL database with pgduckdb and pg_vector extensions.

## Prerequisites

- Docker and Docker Compose installed
- Basic knowledge of PostgreSQL and vector operations

## Project Structure

```
project/
├── docker-compose.yml
├── Dockerfile
├── init-scripts/
│   └── 01-init-extensions.sql
├── config/
│   └── postgresql.conf
└── README.md
```

## Setup Instructions

1. **Clone or create the project directory structure:**
   ```bash
   mkdir -p pgduckdb-setup/{init-scripts,config}
   cd pgduckdb-setup
   # Place your Dockerfile, docker-compose.yml, init-scripts/01-init-extensions.sql, and config/postgresql.conf in the appropriate locations
   ```

2. **Build the Docker image using Docker Compose:**
   ```bash
   docker-compose build
   ```
   This command will use the `Dockerfile` to build the custom PostgreSQL image with the required extensions.

3. **Start the services using docker-compose.yml:**
   ```bash
   docker-compose up -d
   ```
   This will start the PostgreSQL service (and any others defined in your `docker-compose.yml`) in detached mode.

4. **Verify the setup:**
   ```bash
   # Check if containers are running
   docker-compose ps
   
   # Connect to PostgreSQL
   docker-compose exec pgduckdb psql -U postgres -d duckdb
   ```

## Usage Examples

### Connect to the database:
```bash
# Using docker-compose
docker-compose exec pgduckdb psql -U postgres -d duckdb

# Using psql directly (if installed locally)
psql -h localhost -U postgres -d duckdb
```

### Test pg_vector functionality:
```sql
-- Create a test table with vector column
CREATE TABLE test_vectors (
    id SERIAL PRIMARY KEY,
    name TEXT,
    vec vector(3)
);

-- Insert some test data
INSERT INTO test_vectors (name, vec) VALUES 
    ('point1', '[1,2,3]'),
    ('point2', '[4,5,6]'),
    ('point3', '[7,8,9]');

-- Find similar vectors using cosine similarity
SELECT name, vec <=> '[1,2,3]' as distance 
FROM test_vectors 
ORDER BY vec <=> '[1,2,3]' 
LIMIT 5;
```

### Test pg_duckdb functionality:
```sql
-- Create a DuckDB table (syntax may vary based on pg_duckdb version)
SELECT duckdb.query('CREATE TABLE duck_test (id INTEGER, name VARCHAR)');
SELECT duckdb.query('INSERT INTO duck_test VALUES (1, ''test'')');
SELECT duckdb.query('SELECT * FROM duck_test');
```

## Configuration

### Environment Variables

- `POSTGRES_DB`: Database name (default: duckdb)
- `POSTGRES_USER`: Database user (default: postgres)
- `POSTGRES_PASSWORD`: Database password (default: password)

### Ports

- PostgreSQL: `5432`

### Volume Mounts

- `pgduckdb_data`: Persistent storage for PostgreSQL data
- `./init-scripts`: Initialization SQL scripts
- `./config`: Custom PostgreSQL configuration

## Troubleshooting

1. **Extension not found:**
   - Verify the pgduckdb image includes the pg_vector extension
   - Check if extensions are properly loaded in `shared_preload_libraries`

2. **Connection issues:**
   - Ensure ports are not already in use
   - Check Docker network configuration
   - Verify PostgreSQL is ready using health check

3. **Performance issues:**
   - Adjust memory settings in `postgresql.conf`
   - Consider increasing `shared_buffers` and `work_mem`
   - Tune vector index parameters

4. **Data persistence:**
   - Data is stored in the `pgduckdb_data` volume
   - To reset: `docker-compose down -v`

## Cleanup

To stop and remove all containers and volumes:
```bash
docker-compose down -v
```

To keep data but stop containers:
```bash
docker-compose down
```

## Security Notes

- Change default passwords in production
- Enable SSL if needed
- Restrict network access appropriately
- Regular backups recommended for production use