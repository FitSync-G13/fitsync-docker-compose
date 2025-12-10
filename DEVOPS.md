# DevOps Quick Reference

## Database Configuration for CI/CD Pipeline

### What You Need

Each service requires **ONE environment variable**: `DATABASE_URL`

### Connection Strings (AWS RDS with TLS)

Set these in your deployment pipeline (Kubernetes secrets, ECS task definitions, etc.):

```bash
# User Service
DATABASE_URL=postgresql://dbuser:dbpass@your-rds-endpoint.amazonaws.com:5432/userdb?sslmode=require

# Training Service
DATABASE_URL=postgresql://dbuser:dbpass@your-rds-endpoint.amazonaws.com:5432/trainingdb?sslmode=require

# Schedule Service
DATABASE_URL=postgresql://dbuser:dbpass@your-rds-endpoint.amazonaws.com:5432/scheduledb?sslmode=require

# Progress Service
DATABASE_URL=postgresql://dbuser:dbpass@your-rds-endpoint.amazonaws.com:5432/progressdb?sslmode=require
```

### Database Setup

**Option 1: Separate Databases (Recommended)**
- Create 4 databases: `userdb`, `trainingdb`, `scheduledb`, `progressdb`
- Complete isolation between services
- Independent scaling and backup strategies

**Option 2: Single Database**
- Use single database with different schemas or table prefixes
- Lower infrastructure cost
- Shared connection pooling

### TLS/SSL

- **Required:** Add `?sslmode=require` to connection strings
- **Certificates:** Managed automatically by AWS RDS
- **App Configuration:** Services accept RDS certificates automatically
- **No manual certificate management needed**

### Service Requirements

| Service | Port | Additional Env Vars |
|---------|------|-------------------|
| User Service | 3001 | `JWT_SECRET`, `JWT_REFRESH_SECRET`, `REDIS_HOST` |
| Training Service | 3002 | `JWT_SECRET`, `REDIS_HOST`, `USER_SERVICE_URL` |
| Schedule Service | 8003 | `JWT_SECRET`, `REDIS_HOST`, `USER_SERVICE_URL` |
| Progress Service | 8004 | `JWT_SECRET`, `REDIS_HOST`, `USER_SERVICE_URL` |
| Notification Service | 3005 | `REDIS_HOST`, `SMTP_*` configs |
| API Gateway | 4000 | `JWT_SECRET`, All service URLs |
| Frontend | 3000 | `REACT_APP_API_URL` |

### Redis

All services also need Redis for caching and pub/sub:
```bash
REDIS_HOST=your-elasticache-endpoint.cache.amazonaws.com
REDIS_PORT=6379
```

### Kubernetes Example

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: fitsync-user-db
type: Opaque
stringData:
  DATABASE_URL: postgresql://user:pass@rds.amazonaws.com:5432/userdb?sslmode=require
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  template:
    spec:
      containers:
      - name: user-service
        image: your-registry/user-service:latest
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: fitsync-user-db
              key: DATABASE_URL
        - name: PORT
          value: "3001"
        # ... other env vars
```

### ECS Task Definition Example

```json
{
  "containerDefinitions": [{
    "name": "user-service",
    "image": "your-registry/user-service:latest",
    "secrets": [{
      "name": "DATABASE_URL",
      "valueFrom": "arn:aws:secretsmanager:region:account:secret:fitsync/userdb"
    }],
    "environment": [
      {"name": "PORT", "value": "3001"},
      {"name": "NODE_ENV", "value": "production"}
    ]
  }]
}
```

### Health Checks

All services expose `/health` endpoint:
- **User Service:** `http://localhost:3001/health`
- **Training Service:** `http://localhost:3002/health`
- **Schedule Service:** `http://localhost:8003/health`
- **Progress Service:** `http://localhost:8004/health`
- **Notification Service:** `http://localhost:3005/health`
- **API Gateway:** `http://localhost:4000/health`

### Database Migrations

- **Automatic:** Migrations run on service startup
- **No manual intervention needed**
- **Idempotent:** Safe to run multiple times
- **Location:**
  - Node.js services: `src/database/migrate.js`
  - Python services: `main.py` (init_db function)

### Seeding (Optional)

Test data seeding is **automatic in development**, but:
- **Production:** Seeds are skipped when `NODE_ENV=production`
- **Staging:** Keep seeding enabled for testing

### What Changed from Previous Setup

**Before (DEPRECATED):**
- Individual DB parameters (DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD)
- Self-signed SSL certificates in the repo
- Complex dual-configuration logic

**Now (CURRENT):**
- Single `DATABASE_URL` connection string
- TLS via `?sslmode=require` parameter
- AWS RDS manages certificates
- Simpler, cloud-native configuration

### Security Checklist

- [ ] Use AWS Secrets Manager for DATABASE_URL storage
- [ ] Enable RDS encryption at rest
- [ ] Enable RDS encryption in transit (automatic with sslmode=require)
- [ ] Use strong database passwords (generate with secrets manager)
- [ ] Restrict RDS security groups to EKS/ECS security groups only
- [ ] Enable RDS automated backups
- [ ] Set up RDS monitoring and alerting
- [ ] Rotate credentials regularly

### Cost Optimization

**Database Options:**
1. **4 Separate RDS Instances:** Full isolation, higher cost (~$400-800/month)
2. **1 RDS Multi-DB Instance:** Shared resources, medium cost (~$150-300/month)
3. **Aurora Serverless:** Auto-scaling, pay per use (~$100-500/month depending on load)

**Recommendation:** Start with Option 2 (single RDS, multiple databases) and scale to Option 1 if needed.

### Monitoring

Key metrics to monitor:
- Database connection pool utilization
- Query latency
- Failed connection attempts
- SSL/TLS handshake failures
- Database CPU/memory usage
- Slow query logs

### Terraform/IaC Example

```hcl
resource "aws_db_instance" "fitsync" {
  identifier           = "fitsync-db"
  engine              = "postgres"
  engine_version      = "15.4"
  instance_class      = "db.t3.medium"
  allocated_storage   = 100

  db_name  = "userdb"
  username = var.db_username
  password = var.db_password

  multi_az               = true
  storage_encrypted      = true
  backup_retention_period = 7

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = {
    Name = "fitsync-database"
  }
}

# Create additional databases
resource "null_resource" "additional_dbs" {
  provisioner "local-exec" {
    command = <<-EOT
      psql "${aws_db_instance.fitsync.endpoint}" -U ${var.db_username} -c "CREATE DATABASE trainingdb;"
      psql "${aws_db_instance.fitsync.endpoint}" -U ${var.db_username} -c "CREATE DATABASE scheduledb;"
      psql "${aws_db_instance.fitsync.endpoint}" -U ${var.db_username} -c "CREATE DATABASE progressdb;"
    EOT
  }
}
```

## Questions or Issues?

Contact the development team or refer to:
- [DATABASE.md](DATABASE.md) - Detailed database documentation
- [SETUP.md](SETUP.md) - Local development setup
- Service repositories for specific service configuration
