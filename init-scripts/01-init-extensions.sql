-- init-scripts/01-init-extensions.sql
-- This script will run automatically when the container starts for the first time

-- Create the vector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create the pg_duckdb extension (should be available in the pgduckdb image)
CREATE EXTENSION IF NOT EXISTS pg_duckdb;

-- Display installed extensions
SELECT extname, extversion FROM pg_extension WHERE extname IN ('vector', 'pg_duckdb');