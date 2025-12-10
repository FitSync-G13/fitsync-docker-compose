# PostgreSQL SSL Certificates - DEPRECATED

## Important Notice

**These self-signed SSL certificates are DEPRECATED and NOT USED in the current setup.**

The FitSync application has been simplified to use connection string-based database configuration. For production deployments:

- **DevOps will manage TLS certificates** through AWS RDS or your database provider
- Services simply add `?sslmode=require` to their DATABASE_URL
- Certificate management is handled by the cloud provider (AWS RDS, etc.)

## Local Development

For local development using Docker Compose, **SSL/TLS is not required**. The services connect to local PostgreSQL containers without encryption:

```
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname
```

## Production Configuration

For production (AWS RDS with TLS):

```
DATABASE_URL=postgresql://user:pass@host.rds.amazonaws.com:5432/dbname?sslmode=require
```

The application code will automatically:
- Detect `sslmode` in the connection string
- Enable SSL with `rejectUnauthorized: false` to allow cloud provider certificates
- Your DevOps team handles certificate provisioning through AWS/cloud provider

## Files in This Directory

These files were used in a previous iteration and can be safely ignored:
- `server.crt` - Self-signed certificate for localhost
- `server.key` - Private key for the certificate

## Migration Notes

If you're migrating from the old setup:
1. Remove any references to these certificate files in your configuration
2. Use DATABASE_URL environment variable instead
3. Add `?sslmode=require` for production connections only
4. DevOps provisions actual certificates via cloud provider
