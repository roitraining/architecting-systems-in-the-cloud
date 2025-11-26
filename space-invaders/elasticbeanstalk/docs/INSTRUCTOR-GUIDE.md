# Instructor Guide - Space Invaders Elastic Beanstalk Deployment

## 🎓 Teaching Objectives

Students will learn:
- How to use AWS CloudShell
- How to install and use the EB CLI
- How to deploy a Node.js application to Elastic Beanstalk
- How to monitor and troubleshoot deployments
- How to clean up AWS resources

## ⏱️ Time Required

- **Setup & Installation**: 5 minutes
- **Deployment**: 10-15 minutes
- **Testing & Exploration**: 5 minutes
- **Cleanup**: 2 minutes
- **Total**: ~25-30 minutes

## 📝 Pre-Class Setup

### Option 1: Git Repository (Recommended)
1. Push the space-invaders project to a Git repository (GitHub, GitLab, etc.)
2. Ensure repository is public or students have access
3. Provide students with the clone URL

### Option 2: ZIP File Distribution
1. Create a ZIP file of the `space-invaders` directory
2. Upload to a shared location (S3, Google Drive, etc.)
3. Provide students with download link

## 🎯 Key Teaching Points

### 1. CloudShell Benefits
- No local setup required
- Pre-configured AWS credentials
- Consistent environment for all students
- Built-in file upload/download

### 2. EB CLI vs AWS Console
- **EB CLI**: Faster, repeatable, scriptable
- **Console**: Visual, good for learning concepts
- Both are valid approaches

### 3. Elastic Beanstalk Concepts
- **Application**: Container for environments
- **Environment**: Running instance of your app
- **Platform**: Runtime (Node.js, Python, etc.)
- **Environment Tier**: Web server vs Worker

### 4. Cost Management
- Emphasize the importance of terminating environments
- Show how to check running resources in console
- Mention Free Tier eligibility

## 🚨 Common Student Issues

### Issue 1: EB CLI Not Found
**Symptom**: `eb: command not found`

**Solution**:
```bash
export PATH=$PATH:$HOME/.local/bin
```

**Prevention**: Include this in the instructions

### Issue 2: Wrong Directory
**Symptom**: `eb init` fails or can't find files

**Solution**: Ensure students are in `space-invaders/elasticbeanstalk` directory
```bash
pwd  # Should show: .../space-invaders/elasticbeanstalk
```

### Issue 3: Forgot to Run Setup Script
**Symptom**: Deployment succeeds but app shows 404 or blank page

**Solution**: Run the setup script to copy files to `public/` directory
```bash
./setup-deployment.sh
eb deploy
```

### Issue 4: Environment Creation Hangs
**Symptom**: `eb create` takes longer than 15 minutes

**Solution**: 
- Check AWS Service Health Dashboard
- Try a different region
- Terminate and retry: `eb terminate` then `eb create`

### Issue 5: Permission Errors
**Symptom**: AWS permission denied errors

**Solution**: Verify student IAM user/role has these permissions:
- `elasticbeanstalk:*`
- `ec2:*`
- `s3:*`
- `cloudformation:*`
- `autoscaling:*`
- `elasticloadbalancing:*`

## 📊 Demonstration Flow

### 1. Introduction (5 min)
- Explain what Elastic Beanstalk is
- Show the architecture diagram
- Discuss use cases

### 2. Live Demo (10 min)
- Open CloudShell
- Walk through each command
- Explain what's happening at each step
- Show the AWS Console view in parallel

### 3. Student Practice (15 min)
- Students follow along
- Circulate to help with issues
- Encourage students to explore `eb` commands

### 4. Verification (5 min)
- Students open their deployed apps
- Test the game functionality
- Check logs and health status

### 5. Cleanup (5 min)
- Demonstrate `eb terminate`
- Verify in console that resources are deleted
- Discuss importance of cleanup

## 🔍 Assessment Ideas

### Knowledge Check Questions
1. What is the difference between an EB application and environment?
2. What AWS resources does Elastic Beanstalk create automatically?
3. How would you update the application after making code changes?
4. What command shows you the application logs?

### Hands-On Challenges
1. **Easy**: Change the port number in server.js and redeploy
2. **Medium**: Add a new route to server.js that returns JSON
3. **Hard**: Configure environment variables through EB CLI

### Extension Activities
1. Deploy a different application to Elastic Beanstalk
2. Set up a custom domain name
3. Configure auto-scaling rules
4. Set up a CI/CD pipeline

## 📋 Instructor Checklist

Before class:
- [ ] Test the deployment yourself
- [ ] Verify all students have AWS accounts
- [ ] Confirm students have necessary IAM permissions
- [ ] Prepare the repository or ZIP file
- [ ] Test CloudShell access in your region

During class:
- [ ] Share the repository/ZIP link
- [ ] Demonstrate each step before students try
- [ ] Monitor student progress
- [ ] Help troubleshoot issues
- [ ] Verify all students successfully deploy

After class:
- [ ] Verify all students terminated their environments
- [ ] Check for any orphaned resources
- [ ] Collect feedback on the exercise

## 💡 Tips for Success

1. **Start Simple**: Don't overwhelm with all EB features at once
2. **Use Consistent Names**: Have all students use the same environment name for easier troubleshooting
3. **Show Console Too**: Display the AWS Console alongside CLI to reinforce concepts
4. **Emphasize Cleanup**: Make cleanup part of the grade/completion criteria
5. **Record the Session**: Students can reference it later

## 🔗 Additional Resources for Students

- [AWS Elastic Beanstalk FAQs](https://aws.amazon.com/elasticbeanstalk/faqs/)
- [EB CLI Command Reference](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb3-cmd-commands.html)
- [Node.js Platform Guide](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create-deploy-nodejs.html)

## 📞 Support Resources

If students encounter issues outside of class:
1. AWS Documentation
2. AWS re:Post (community forum)
3. Office hours
4. Course discussion board

## 🎉 Success Metrics

Students successfully completed the lab if they:
- ✅ Deployed the application to Elastic Beanstalk
- ✅ Can access the game via the EB URL
- ✅ Viewed logs using `eb logs`
- ✅ Terminated the environment properly
- ✅ Can explain the basic EB concepts

---

**Questions or Issues?** Contact [your contact info]
