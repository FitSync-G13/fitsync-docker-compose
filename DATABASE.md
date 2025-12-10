# Database Configuration Guide

## Overview

FitSync uses **PostgreSQL** for all microservices. The configuration has been simplified to use **connection strings only** via the `DATABASE_URL` environment variable.

## For DevOps / Production Deployment

### AWS RDS Configuration (CI/CD Pipeline)

Each service requires a single environment variable:

```bash
DATABASE_URL=postgresql://username:password@your-rds-endpoint.amazonaws.com:5432/dbname?sslmode=require
```

### Per-Service Connection Strings

Set these environment variables for each service in your deployment pipeline:

| Service | Environment Variable |
|---------|---------------------|
| User Service | `DATABASE_URL=postgresql://user:pass@rds-host:5432/userdb?sslmode=require` |
| Training Service | `DATABASE_URL=postgresql://user:pass@rds-host:5432/trainingdb?sslmode=require` |
| Schedule Service | `DATABASE_URL=postgresql://user:pass@rds-host:5432/scheduledb?sslmode=require` |
| Progress Service | `DATABASE_URL=postgresql://user:pass@rds-host:5432/progressdb?sslmode=require` |

### TLS/SSL Configuration

- **TLS is enabled** by adding `?sslmode=require` to the connection string
- **Certificates are managed** by AWS RDS automatically
- Services use `rejectUnauthorized: false` to accept cloud provider certificates
- No manual certificate management required

### Database Setup Notes

1. Create 4 separate databases (or use a single database with different schemas if preferred)
2. Ensure your RDS security groups allow connections from your EKS/ECS cluster
3. Use AWS Secrets Manager or similar for storing connection strings
4. Database migrations run automatically on service startup

## For Developers / Local Testing

### Option 1: Using Docker Compose (Recommended)

The included `docker-compose.yml` sets up 4 separate PostgreSQL containers:

```bash
# Start all services including databases
docker compose up -d

# Services will connect to local PostgreSQL without TLS
# Connection strings are pre-configured in docker-compose.yml
```

**No manual configuration needed** - everything is pre-configured in docker-compose.yml.

### Option 2: Single Local PostgreSQL Instance

If you want to run services outside Docker and use a single local PostgreSQL:

1. **Install PostgreSQL locally**

2. **Create databases:**
   ```sql
   CREATE DATABASE userdb;
   CREATE DATABASE trainingdb;
   CREATE DATABASE scheduledb;
   CREATE DATABASE progressdb;
   ```

3. **Set environment variables** (create `.env` files from `.env.example` in each service):

   For user-service:
   ```
   DATABASE_URL=postgresql://postgres:yourpassword@localhost:5432/userdb
   ```

   For training-service:
   ```
   DATABASE_URL=postgresql://postgres:yourpassword@localhost:5432/trainingdb
   ```

   For schedule-service:
   ```
   DATABASE_URL=postgresql://postgres:yourpassword@localhost:5432/scheduledb
   ```

   For progress-service:
   ```
   DATABASE_URL=postgresql://postgres:yourpassword@localhost:5432/progressdb
   ```

### Option 3: Using Cloud Database for Local Dev

You can point your local services to a cloud database:

```bash
# Add ?sslmode=require for cloud databases
DATABASE_URL=postgresql://user:pass@your-dev-db.amazonaws.com:5432/dbname?sslmode=require
```

## Connection String Format

### Basic Format
```
postgresql://[user]:[password]@[host]:[port]/[database]
```

### With TLS (Production)
```
postgresql://[user]:[password]@[host]:[port]/[database]?sslmode=require
```

### Examples

**Local (no TLS):**
```
DATABASE_URL=postgresql://fitsync:fitsync123@localhost:5432/userdb
```

**Production (with TLS):**
```
DATABASE_URL=postgresql://admin:SecurePass123@db.prod.example.com:5432/userdb?sslmode=require
```

## Migration from Old Configuration

If you're updating from the previous setup that used individual DB parameters:

### Old Way (DEPRECATED):
```bash
DB_HOST=localhost
DB_PORT=5432
DB_NAME=userdb
DB_USER=fitsync
DB_PASSWORD=fitsync123
```

### New Way (CURRENT):
```bash
DATABASE_URL=postgresql://fitsync:fitsync123@localhost:5432/userdb
```

**The old individual parameters are no longer supported.** All services now require `DATABASE_URL`.

## Troubleshooting

### Service fails to start with "DATABASE_URL is required"

**Solution:** Ensure DATABASE_URL environment variable is set for the service.

### SSL/TLS connection errors in production

**Solution:** Verify `?sslmode=require` is in your connection string and your RDS instance has SSL enabled.

### Local services can't connect to database

**Solution:**
- Ensure PostgreSQL is running: `docker compose ps` or `pg_isadmin` locally
- Verify connection string format
- Check database exists: `psql -l`

### "rejectUnauthorized" concerns

This setting allows self-signed certificates from cloud providers (AWS RDS, etc.). Your DevOps team provisions the actual certificates through the cloud provider, and the application accepts them automatically.

## Security Best Practices

1. **Never commit DATABASE_URL to git** - use environment variables
2. **Use strong passwords** for production databases
3. **Enable RDS encryption at rest** for production
4. **Use AWS Secrets Manager** to store connection strings
5. **Rotate credentials regularly**
6. **Enable RDS automated backups**
7. **Use separate databases** for dev/staging/production

## Questions?

- For CI/CD pipeline issues: Contact DevOps team
- For local development: See [SETUP.md](SETUP.md) or [QUICKSTART.md](QUICKSTART.md)
- For database schema: Check `src/database/migrate.js` (Node.js) or `main.py` (Python) in each service
