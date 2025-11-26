# Space Invaders - Elastic Beanstalk Architecture

## 🏗️ Deployment Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        AWS Cloud                             │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │         Elastic Beanstalk Environment              │    │
│  │                                                     │    │
│  │  ┌──────────────────────────────────────────┐     │    │
│  │  │     Application Load Balancer (ALB)      │     │    │
│  │  │         (Port 80 → Port 8080)            │     │    │
│  │  └──────────────┬───────────────────────────┘     │    │
│  │                 │                                  │    │
│  │                 ▼                                  │    │
│  │  ┌──────────────────────────────────────────┐     │    │
│  │  │         EC2 Instance (t3.micro)          │     │    │
│  │  │                                          │     │    │
│  │  │  ┌────────────────────────────────┐     │     │    │
│  │  │  │   Node.js 18 Runtime           │     │     │    │
│  │  │  │                                │     │     │    │
│  │  │  │  ┌──────────────────────┐      │     │     │    │
│  │  │  │  │   Express Server     │      │     │     │    │
│  │  │  │  │   (server.js)        │      │     │     │    │
│  │  │  │  │   Port: 8080         │      │     │     │    │
│  │  │  │  └──────────┬───────────┘      │     │     │    │
│  │  │  │             │                  │     │     │    │
│  │  │  │             ▼                  │     │     │    │
│  │  │  │  ┌──────────────────────┐      │     │     │    │
│  │  │  │  │   Static Files       │      │     │     │    │
│  │  │  │  │   (public/)          │      │     │     │    │
│  │  │  │  │   - index.html       │      │     │     │    │
│  │  │  │  │   - app.js           │      │     │     │    │
│  │  │  │  │   - style.css        │      │     │     │    │
│  │  │  │  │   - *.svg            │      │     │     │    │
│  │  │  │  └──────────────────────┘      │     │     │    │
│  │  │  └────────────────────────────────┘     │     │    │
│  │  └──────────────────────────────────────────┘     │    │
│  │                                                     │    │
│  │  ┌──────────────────────────────────────────┐     │    │
│  │  │         Security Group                    │     │    │
│  │  │   - Inbound: Port 80 (HTTP)              │     │    │
│  │  │   - Outbound: All traffic                │     │    │
│  │  └──────────────────────────────────────────┘     │    │
│  │                                                     │    │
│  │  ┌──────────────────────────────────────────┐     │    │
│  │  │         CloudWatch Logs                   │     │    │
│  │  │   - Application logs                     │     │    │
│  │  │   - Server logs                          │     │    │
│  │  └──────────────────────────────────────────┘     │    │
│  │                                                     │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
└─────────────────────────────────────────────────────────────┘

                            ▲
                            │
                            │ HTTPS
                            │
                    ┌───────┴────────┐
                    │   Internet     │
                    │   Users        │
                    └────────────────┘
```

## 🔄 Request Flow

1. **User** opens browser and navigates to EB URL
2. **Load Balancer** receives request on port 80
3. **Load Balancer** forwards to EC2 instance on port 8080
4. **Express Server** receives request
5. **Express Server** serves static files from `public/` directory
6. **Browser** renders the Space Invaders game

## 📦 What Elastic Beanstalk Creates

When you run `eb create`, AWS automatically provisions:

| Resource | Purpose |
|----------|---------|
| **EC2 Instance** | Runs your Node.js application |
| **Load Balancer** | Distributes traffic, provides single URL |
| **Security Group** | Firewall rules for your instance |
| **Auto Scaling Group** | Can scale instances up/down (configured for 1 instance) |
| **CloudWatch Logs** | Stores application and server logs |
| **S3 Bucket** | Stores application versions |
| **IAM Roles** | Permissions for EB to manage resources |

## 🎯 Application Structure

```
Your Local Files                    Deployed on EC2
─────────────────                   ───────────────

elasticbeanstalk/
├── server.js          ──────────►  /var/app/current/server.js
├── package.json       ──────────►  /var/app/current/package.json
└── public/            ──────────►  /var/app/current/public/
    ├── index.html                      ├── index.html
    ├── app.js                          ├── app.js
    ├── style.css                       ├── style.css
    └── ...                             └── ...
```

## 🔐 Security

- **Load Balancer**: Accepts HTTP traffic from internet (port 80)
- **EC2 Instance**: Only accepts traffic from Load Balancer (port 8080)
- **Security Groups**: Automatically configured by Elastic Beanstalk
- **IAM Roles**: Least privilege access for EB operations

## 📊 Monitoring

Elastic Beanstalk provides built-in monitoring:

- **Health Dashboard**: Overall environment health
- **Metrics**: CPU, memory, network, request count
- **Logs**: Application logs accessible via `eb logs`
- **Alarms**: Can configure CloudWatch alarms for issues

## 🔄 Deployment Process

```
Local Machine/CloudShell              AWS Elastic Beanstalk
─────────────────────────             ─────────────────────

1. eb create
   │
   ├──► Package application files
   │
   ├──► Upload to S3
   │
   └──► Trigger EB deployment
                                      2. EB receives deployment
                                         │
                                         ├──► Create EC2 instance
                                         │
                                         ├──► Install Node.js 18
                                         │
                                         ├──► Download app from S3
                                         │
                                         ├──► Run npm install
                                         │
                                         ├──► Start application
                                         │    (npm start → node server.js)
                                         │
                                         └──► Configure Load Balancer

3. eb open
   │
   └──► Opens browser to EB URL
                                      4. Application running!
                                         │
                                         └──► Serving on port 8080
```

## 💰 Cost Breakdown

| Resource | Free Tier | After Free Tier |
|----------|-----------|-----------------|
| EC2 t3.micro | 750 hrs/month | ~$0.01/hour |
| Load Balancer | Not included | ~$0.025/hour |
| Data Transfer | 1 GB/month | ~$0.09/GB |
| **Estimated Monthly** | **$0** | **~$20-25** |

**💡 Tip**: Always terminate environments when not in use!

## 🎓 Learning Outcomes

By deploying this application, students learn:

1. **Platform as a Service (PaaS)**: How EB abstracts infrastructure
2. **Load Balancing**: How traffic is distributed
3. **Auto Scaling**: How applications can scale (even if not configured)
4. **Logging & Monitoring**: How to troubleshoot cloud applications
5. **Infrastructure as Code**: How EB CLI automates deployment
6. **Cost Management**: Importance of cleaning up resources

## 🔗 Related AWS Services

- **EC2**: Virtual servers (EB uses these)
- **ELB**: Load balancing (EB creates ALB)
- **Auto Scaling**: Automatic scaling (EB configures)
- **CloudWatch**: Monitoring and logs
- **S3**: Storage for application versions
- **IAM**: Permissions and roles
- **CloudFormation**: Infrastructure as code (EB uses internally)

---

**Next Steps**: See `README-ElasticBeanstalk.md` for deployment instructions
