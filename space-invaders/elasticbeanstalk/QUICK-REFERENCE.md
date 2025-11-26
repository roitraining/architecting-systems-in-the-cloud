# Space Invaders - EB Deployment Quick Reference

## 🚀 Quick Start Commands

```bash
# 1. Install EB CLI
pip install awsebcli --user
export PATH=$PATH:$HOME/.local/bin

# 2. Navigate to project
cd space-invaders/elasticbeanstalk

# 3. Setup files
chmod +x setup-deployment.sh
./setup-deployment.sh

# 4. Initialize EB
eb init

# 5. Create and deploy
eb create space-invaders-env

# 6. Open app
eb open

# 7. Cleanup when done
eb terminate space-invaders-env
```

## 📋 Essential Commands

| Command | What it does |
|---------|--------------|
| `eb init` | Set up new EB application |
| `eb create <name>` | Create environment & deploy |
| `eb deploy` | Update existing environment |
| `eb open` | Open app in browser |
| `eb status` | Check environment status |
| `eb health` | Check app health |
| `eb logs` | View application logs |
| `eb terminate <name>` | Delete environment |

## 🐛 Troubleshooting

**EB command not found?**
```bash
export PATH=$PATH:$HOME/.local/bin
```

**App shows blank page?**
```bash
./setup-deployment.sh
eb deploy
```

**Need to see errors?**
```bash
eb logs
```

**Want to start over?**
```bash
eb terminate space-invaders-env
eb create space-invaders-env
```

## ✅ Checklist

- [ ] Installed EB CLI
- [ ] Ran setup script
- [ ] Initialized EB application
- [ ] Created environment
- [ ] Opened and tested app
- [ ] Terminated environment (cleanup!)

## 💰 Remember to Clean Up!

Always run `eb terminate` when done to avoid charges!
