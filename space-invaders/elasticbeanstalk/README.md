# Space Invaders - Elastic Beanstalk Deployment

Complete guide for deploying Space Invaders to AWS Elastic Beanstalk using CloudShell.

## 📚 Documentation Overview

This directory contains everything you need to deploy Space Invaders to AWS Elastic Beanstalk:

| Document | Audience | Purpose |
|----------|----------|---------|
| **README-ElasticBeanstalk.md** | Students | Complete step-by-step deployment guide |
| **QUICK-REFERENCE.md** | Students | One-page command cheat sheet |
| **INSTRUCTOR-GUIDE.md** | Instructors | Teaching guide with tips and solutions |
| **ARCHITECTURE.md** | Both | Visual architecture and concepts |
| **TROUBLESHOOTING.md** | Both | Common issues and solutions |

## 🚀 Quick Start

**For Students**: Start with `README-ElasticBeanstalk.md`

**For Instructors**: Read `INSTRUCTOR-GUIDE.md` first

**Need Help?**: Check `TROUBLESHOOTING.md`

## 📁 Files in This Directory

```
elasticbeanstalk/
├── README.md                          # This file
├── README-ElasticBeanstalk.md        # Student deployment guide
├── QUICK-REFERENCE.md                # Command cheat sheet
├── INSTRUCTOR-GUIDE.md               # Teaching guide
├── ARCHITECTURE.md                   # Architecture diagrams
├── TROUBLESHOOTING.md                # Common issues
├── server.js                         # Express web server
├── package.json                      # Node.js configuration
├── setup-deployment.sh               # Setup script
├── .ebignore                         # Files to exclude
└── .gitignore                        # Git ignore rules
```

## ⚡ Super Quick Deploy

```bash
# 1. Install EB CLI
pip install awsebcli --user
export PATH=$PATH:$HOME/.local/bin

# 2. Setup and deploy
cd space-invaders/elasticbeanstalk
./setup-deployment.sh
eb init
eb create space-invaders-env
eb open

# 3. Cleanup when done
eb terminate space-invaders-env
```

## 🎯 What You'll Learn

- Using AWS CloudShell
- Deploying with EB CLI
- Node.js on Elastic Beanstalk
- AWS resource management
- Application monitoring
- Cost optimization

## ✅ Prerequisites

- AWS Account
- Access to AWS CloudShell
- Basic command line knowledge
- No local setup required!

## 🎓 Educational Value

This deployment teaches:
- **Platform as a Service (PaaS)** concepts
- **Infrastructure automation** with EB CLI
- **Load balancing** and traffic distribution
- **Application monitoring** and logging
- **Cost management** in the cloud

## 💰 Cost Information

- **Free Tier**: Eligible for 750 hours/month
- **After Free Tier**: ~$20-25/month if left running
- **Best Practice**: Terminate when not in use

## 🔗 Additional Resources

- [AWS Elastic Beanstalk Documentation](https://docs.aws.amazon.com/elasticbeanstalk/)
- [EB CLI Documentation](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3.html)
- [Node.js on EB Guide](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create-deploy-nodejs.html)

## 🆘 Need Help?

1. Check `TROUBLESHOOTING.md` for common issues
2. Run `eb logs` to see application logs
3. Check AWS Service Health Dashboard
4. Ask your instructor

## 🎉 Success Criteria

You've successfully completed the deployment when:
- ✅ Application is accessible via EB URL
- ✅ Space Invaders game loads and plays
- ✅ You can view logs with `eb logs`
- ✅ Environment health shows "Green"
- ✅ You've terminated the environment (cleanup)

---

**Ready to deploy?** Open `README-ElasticBeanstalk.md` and follow the steps!
