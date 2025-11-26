# Space Invaders - Elastic Beanstalk Deployment Guide

Deploy Space Invaders to AWS Elastic Beanstalk using the EB CLI in CloudShell.

## 📋 Prerequisites

- AWS Account with appropriate permissions
- Access to AWS CloudShell (available in AWS Console)

## 🚀 Deployment Steps for Students

### Step 1: Open AWS CloudShell

1. Log into the AWS Management Console
2. Click the **CloudShell** icon (terminal icon) in the top navigation bar
3. Wait for CloudShell to initialize (takes ~30 seconds)

### Step 2: Install EB CLI

```bash
pip install awsebcli --user
export PATH=$PATH:$HOME/.local/bin
eb --version
```

You should see output like: `EB CLI 3.x.x (Python 3.x.x)`

### Step 3: Upload the Project Files

**Option A: Using Git (Recommended)**
```bash
git clone <your-repository-url>
cd space-invaders/elasticbeanstalk
```

**Option B: Upload ZIP file**
1. Download the project as a ZIP file
2. In CloudShell, click **Actions** → **Upload file**
3. Upload the ZIP file
4. Extract it:
```bash
unzip space-invaders.zip
cd space-invaders/elasticbeanstalk
```

### Step 4: Verify Files

Verify that the game files are present:

```bash
ls -la public/
```

You should see: `index.html`, `app.js`, `style.css`, `controllers/`, `views/`, and game assets (*.svg files).

### Step 5: Initialize Elastic Beanstalk

```bash
eb init
```

Answer the prompts:
- **Select a default region**: Choose your preferred region (e.g., `10` for us-east-1)
- **Application name**: Press Enter to accept `elasticbeanstalk` or type `space-invaders`
- **Platform**: Select `Node.js`
- **Platform branch**: Select `Node.js 18 running on 64bit Amazon Linux 2023`
- **CodeCommit**: Type `n` (we're not using CodeCommit)
- **SSH**: Type `n` (not needed for this demo)

### Step 6: Create Environment and Deploy

```bash
eb create space-invaders-env
```

This command will:
- Create an Elastic Beanstalk environment
- Provision AWS resources (EC2 instance, security groups, load balancer)
- Install Node.js dependencies
- Deploy your application

⏱️ **This takes 5-10 minutes.** You'll see status updates in the terminal.

### Step 7: Open Your Application

Once deployment completes, open the app in your browser:

```bash
eb open
```

This will display the URL and attempt to open it. If it doesn't open automatically, copy the URL from the output.

### Step 8: Verify Deployment

Check the status of your environment:

```bash
eb status
```

Check application health:

```bash
eb health
```

### Step 9: View Application Logs (Optional)

If you need to troubleshoot:

```bash
eb logs
```

### Step 10: Make Updates (Optional)

If you make changes to the code:

```bash
# After making changes, redeploy:
eb deploy
```

### Step 11: Cleanup (Important!)

When you're done with the demo, terminate the environment to avoid charges:

```bash
eb terminate space-invaders-env
```

Type the environment name to confirm: `space-invaders-env`

---

## 📁 Project Structure

```
elasticbeanstalk/
├── server.js              # Express server
├── package.json           # Node.js dependencies
├── .ebignore             # Files to exclude from deployment
├── setup-deployment.sh    # Setup script
└── public/               # Static game files (created by setup script)
    ├── index.html
    ├── app.js
    ├── style.css
    ├── controllers/
    ├── views/
    └── *.svg (game assets)
```

## 🔧 How It Works

1. **Express Server**: `server.js` creates a simple web server that serves static files
2. **Static Files**: All game files (HTML, JS, CSS, images) are in the `public/` directory
3. **Node.js Platform**: Elastic Beanstalk runs this on Amazon Linux 2023 with Node.js 18
4. **Port Configuration**: The app listens on port 8080 (or the PORT environment variable set by EB)

## 🎯 Key EB CLI Commands

| Command | Description |
|---------|-------------|
| `eb init` | Initialize a new EB application |
| `eb create <env-name>` | Create and deploy a new environment |
| `eb deploy` | Deploy updates to existing environment |
| `eb open` | Open the application URL in browser |
| `eb status` | Show environment status |
| `eb health` | Show application health |
| `eb logs` | Retrieve and display logs |
| `eb terminate <env-name>` | Delete the environment |
| `eb list` | List all environments |

## 🐛 Troubleshooting

### Application won't load
```bash
# Check logs for errors
eb logs

# Check environment health
eb health --refresh
```

### Deployment fails
- Verify `package.json` is present
- Ensure `server.js` has no syntax errors
- Check that `public/` directory exists with game files

### EB CLI not found after installation
```bash
# Add to PATH
export PATH=$PATH:$HOME/.local/bin

# Verify installation
which eb
```

### Environment creation times out
- Check AWS Service Health Dashboard
- Try a different region
- Ensure your AWS account has appropriate permissions

## 💰 Cost Considerations

- **Free Tier**: Eligible for AWS Free Tier (750 hours/month of t2.micro or t3.micro)
- **After Free Tier**: ~$15-20/month if left running
- **Best Practice**: Terminate environments when not in use

## 📚 Additional Resources

- [AWS Elastic Beanstalk Documentation](https://docs.aws.amazon.com/elasticbeanstalk/)
- [EB CLI Documentation](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3.html)
- [Node.js on Elastic Beanstalk](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create-deploy-nodejs.html)

## ✅ Success Criteria

Students should be able to:
1. ✅ Install and configure EB CLI in CloudShell
2. ✅ Initialize an Elastic Beanstalk application
3. ✅ Deploy the Space Invaders game
4. ✅ Access the running application via URL
5. ✅ View logs and monitor health
6. ✅ Terminate the environment to clean up resources