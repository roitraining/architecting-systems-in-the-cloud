# Troubleshooting Guide - Space Invaders on Elastic Beanstalk

## 🔍 Common Issues and Solutions

### Issue 1: `eb: command not found`

**Symptom**: After installing EB CLI, the `eb` command doesn't work

**Cause**: The EB CLI installation directory is not in your PATH

**Solution**:
```bash
export PATH=$PATH:$HOME/.local/bin
eb --version
```

**Permanent Fix** (for CloudShell):
```bash
echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
source ~/.bashrc
```

---

### Issue 2: Application Shows 404 or Blank Page

**Symptom**: Deployment succeeds, but opening the URL shows a 404 error or blank page

**Cause**: The `public/` directory doesn't exist or is empty

**Solution**:
```bash
# Make sure you're in the elasticbeanstalk directory
cd space-invaders/elasticbeanstalk

# Run the setup script
chmod +x setup-deployment.sh
./setup-deployment.sh

# Verify files were copied
ls -la public/

# Redeploy
eb deploy
```

---

### Issue 3: `eb init` Fails with "No Region Specified"

**Symptom**: `eb init` command fails immediately

**Cause**: AWS credentials not configured or region not set

**Solution** (in CloudShell):
```bash
# CloudShell should have credentials automatically
# Just specify region during eb init, or:
eb init --region us-east-1
```

---

### Issue 4: Environment Creation Takes Too Long

**Symptom**: `eb create` runs for more than 15 minutes

**Cause**: AWS service issue, resource limits, or network problems

**Solution**:
```bash
# Cancel the current operation (Ctrl+C)
# Check status
eb status

# If environment is in "Launching" state, wait a bit more
# If it's been > 20 minutes, terminate and retry
eb terminate space-invaders-env

# Try again, possibly in a different region
eb create space-invaders-env --region us-west-2
```

---

### Issue 5: "Service:AmazonCloudFormation, Message:Stack creation failed"

**Symptom**: Environment creation fails with CloudFormation error

**Cause**: Usually insufficient permissions or resource limits

**Solution**:
```bash
# Check the detailed error
eb events

# Common fixes:
# 1. Verify IAM permissions (need EB, EC2, ELB, CloudFormation access)
# 2. Check service quotas in AWS Console
# 3. Try a different instance type
eb create space-invaders-env --instance-type t3.small
```

---

### Issue 6: Application Logs Show "Cannot find module 'express'"

**Symptom**: App deploys but crashes, logs show missing dependencies

**Cause**: `package.json` not found or `npm install` failed

**Solution**:
```bash
# Verify package.json exists
ls -la package.json

# Check package.json content
cat package.json

# Ensure you're deploying from the right directory
pwd  # Should be: .../space-invaders/elasticbeanstalk

# Redeploy
eb deploy
```

---

### Issue 7: "ERROR: This directory has not been set up with the EB CLI"

**Symptom**: `eb` commands fail with this error

**Cause**: You're not in a directory that has been initialized with `eb init`

**Solution**:
```bash
# Navigate to the correct directory
cd space-invaders/elasticbeanstalk

# Initialize if not done yet
eb init

# Or check if .elasticbeanstalk directory exists
ls -la .elasticbeanstalk/
```

---

### Issue 8: "Insufficient permissions to perform this action"

**Symptom**: AWS permission errors during deployment

**Cause**: IAM user/role lacks necessary permissions

**Required Permissions**:
- `elasticbeanstalk:*`
- `ec2:*`
- `elasticloadbalancing:*`
- `autoscaling:*`
- `cloudformation:*`
- `s3:*`
- `cloudwatch:*`
- `iam:PassRole`

**Solution**: Contact your AWS administrator to grant these permissions

---

### Issue 9: Environment Health is "Degraded" or "Severe"

**Symptom**: `eb health` shows red or yellow status

**Cause**: Application errors, failed health checks, or resource issues

**Solution**:
```bash
# Check detailed health
eb health --refresh

# View logs for errors
eb logs

# Common fixes:
# 1. Check if server.js has syntax errors
# 2. Verify port 8080 is being used
# 3. Ensure health check endpoint works
curl http://your-eb-url/health

# Redeploy if you fixed code
eb deploy
```

---

### Issue 10: Can't Access Application URL

**Symptom**: `eb open` doesn't work or URL times out

**Cause**: Security group misconfiguration or environment not ready

**Solution**:
```bash
# Check environment status
eb status

# Wait for environment to be "Ready"
# Check if URL is correct
eb status | grep CNAME

# Try accessing directly
curl http://your-environment-url

# Check security groups in AWS Console
# Ensure port 80 is open to 0.0.0.0/0
```

---

### Issue 11: "Platform version is no longer supported"

**Symptom**: Warning about deprecated platform version

**Cause**: Using an old Node.js platform version

**Solution**:
```bash
# List available platforms
eb platform list

# Update to latest platform
eb upgrade

# Or specify during creation
eb create space-invaders-env --platform "Node.js 18 running on 64bit Amazon Linux 2023"
```

---

### Issue 12: Changes Not Appearing After `eb deploy`

**Symptom**: Code changes don't show up in deployed app

**Cause**: Browser cache or deployment didn't complete

**Solution**:
```bash
# Check deployment status
eb events

# Force browser refresh (Ctrl+Shift+R or Cmd+Shift+R)

# Verify files are correct locally
cat server.js

# Try redeploying with verbose output
eb deploy --verbose

# Check logs to see if new version is running
eb logs
```

---

## 🛠️ Debugging Commands

### Check Environment Status
```bash
eb status
```

### View Recent Events
```bash
eb events
```

### View Application Logs
```bash
eb logs
```

### Check Application Health
```bash
eb health --refresh
```

### SSH into Instance (if configured)
```bash
eb ssh
```

### View Environment Configuration
```bash
eb config
```

### List All Environments
```bash
eb list
```

---

## 📋 Pre-Deployment Checklist

Before running `eb create`, verify:

- [ ] You're in the `elasticbeanstalk/` directory
- [ ] `setup-deployment.sh` has been run
- [ ] `public/` directory exists and contains game files
- [ ] `package.json` exists and has correct dependencies
- [ ] `server.js` exists and has no syntax errors
- [ ] EB CLI is installed and in PATH

---

## 🔄 Starting Fresh

If everything is broken and you want to start over:

```bash
# 1. Terminate the environment
eb terminate space-invaders-env

# 2. Remove EB configuration
rm -rf .elasticbeanstalk/

# 3. Clean up generated files
rm -rf public/

# 4. Start from scratch
./setup-deployment.sh
eb init
eb create space-invaders-env
```

---

## 📞 Getting Help

### Check AWS Service Health
https://status.aws.amazon.com/

### AWS Documentation
https://docs.aws.amazon.com/elasticbeanstalk/

### AWS re:Post (Community Forum)
https://repost.aws/

### EB CLI GitHub Issues
https://github.com/aws/aws-elastic-beanstalk-cli/issues

---

## 💡 Pro Tips

1. **Always check logs first**: `eb logs` is your best friend
2. **Use verbose mode**: Add `--verbose` to commands for more details
3. **Check AWS Console**: Sometimes the console shows more info than CLI
4. **Save your work**: Commit to Git before making major changes
5. **Test locally first**: Run `npm start` locally before deploying
6. **Monitor costs**: Check AWS Billing Dashboard regularly
7. **Clean up**: Always `eb terminate` when done

---

## ✅ Verification Steps

After deployment, verify everything works:

```bash
# 1. Check status
eb status
# Should show: Status: Ready

# 2. Check health
eb health
# Should show: Green

# 3. Get URL
eb status | grep CNAME

# 4. Test health endpoint
curl http://your-url/health
# Should return: {"status":"healthy"}

# 5. Open in browser
eb open
# Should show Space Invaders game

# 6. Test game functionality
# - Click "Start Game"
# - Move ship with arrow keys
# - Shoot with spacebar
```

If all these work, you're good to go! 🎉
