# Space Invaders Deployment - Student Handout

**Course**: AWS Cloud Architecture  
**Lab**: Elastic Beanstalk Deployment  
**Time**: 25-30 minutes

---

## 🎯 Objective

Deploy the Space Invaders game to AWS Elastic Beanstalk using CloudShell and the EB CLI.

## 📋 Prerequisites

- ✅ AWS Account access
- ✅ Access to AWS CloudShell
- ✅ Project files (provided by instructor)

---

## 🚀 Deployment Steps

### Step 1: Open CloudShell (2 min)

1. Log into AWS Console
2. Click the **CloudShell** icon (terminal) in top navigation
3. Wait for CloudShell to initialize

### Step 2: Install EB CLI (3 min)

```bash
pip install awsebcli --user
export PATH=$PATH:$HOME/.local/bin
eb --version
```

✅ **Checkpoint**: You should see `EB CLI 3.x.x`

### Step 3: Get Project Files (2 min)

**Option A - Git**:
```bash
git clone [INSTRUCTOR_PROVIDES_URL]
cd space-invaders/elasticbeanstalk
```

**Option B - Upload**:
1. Download ZIP from [INSTRUCTOR_PROVIDES_LINK]
2. In CloudShell: Actions → Upload file
3. Extract: `unzip space-invaders.zip`
4. Navigate: `cd space-invaders/elasticbeanstalk`

### Step 4: Verify Files (1 min)

```bash
ls -la public/
```

✅ **Checkpoint**: You should see game files (index.html, app.js, style.css, etc.)

### Step 5: Initialize EB (3 min)

```bash
eb init
```

**Answer the prompts**:
- Region: `[YOUR_REGION]` (e.g., 10 for us-east-1)
- Application name: Press Enter or type `space-invaders`
- Platform: Select `Node.js`
- Platform branch: Select `Node.js 18`
- CodeCommit: `n`
- SSH: `n`

✅ **Checkpoint**: You should see "Application space-invaders has been created"

### Step 6: Create Environment (10-15 min)

```bash
eb create space-invaders-env
```

⏱️ **This takes 10-15 minutes.** Watch the status updates.

✅ **Checkpoint**: You should see "Successfully launched environment"

### Step 7: Open Application (1 min)

```bash
eb open
```

🎮 **Test the game**: Click "Start Game" and play!

### Step 8: Verify Deployment (2 min)

```bash
# Check status
eb status

# Check health
eb health

# View logs
eb logs
```

✅ **Checkpoint**: Status should be "Ready" and health should be "Green"

---

## 🧹 Cleanup (IMPORTANT!)

**When you're done**, terminate the environment to avoid charges:

```bash
eb terminate space-invaders-env
```

Type the environment name to confirm: `space-invaders-env`

⚠️ **Don't skip this step!** Leaving the environment running costs money.

---

## 📝 Lab Questions

Answer these questions for your lab report:

1. What AWS resources did Elastic Beanstalk create automatically?
2. What is the URL of your deployed application?
3. What command did you use to view application logs?
4. What is the difference between `eb status` and `eb health`?
5. Why is it important to terminate the environment after the lab?

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| `eb: command not found` | Run: `export PATH=$PATH:$HOME/.local/bin` |
| App shows 404 | Run: `./setup-deployment.sh` then `eb deploy` |
| Deployment takes too long | Wait 15 min, then check `eb events` |
| Can't access URL | Check `eb status` - wait for "Ready" |

**Need more help?** See `TROUBLESHOOTING.md` or ask your instructor.

---

## ✅ Submission Checklist

Before submitting your lab:

- [ ] Application deployed successfully
- [ ] Game is playable at EB URL
- [ ] Screenshot of working game
- [ ] Output of `eb status` command
- [ ] Output of `eb health` command
- [ ] Lab questions answered
- [ ] Environment terminated (screenshot of termination)

---

## 📚 Additional Resources

- Full guide: `README-ElasticBeanstalk.md`
- Quick reference: `QUICK-REFERENCE.md`
- Architecture: `ARCHITECTURE.md`
- Troubleshooting: `TROUBLESHOOTING.md`

---

## 🎓 What You Learned

- ✅ Using AWS CloudShell
- ✅ Installing and using EB CLI
- ✅ Deploying Node.js applications
- ✅ Monitoring application health
- ✅ Managing AWS resources
- ✅ Cost management best practices

---

**Questions?** Ask your instructor or check the documentation!

**Good luck! 🚀**
