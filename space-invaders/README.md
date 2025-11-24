# Space Invaders - AWS Deployment Demo

Demo application for AWS course showing multiple deployment methods.

## Project Structure

```
space-invaders/
├── src/                    # Shared source code
│   ├── index.html         # Main HTML file
│   ├── app.js             # AngularJS application
│   ├── style.css          # Styles
│   ├── controllers/       # AngularJS controllers
│   ├── views/             # HTML templates
│   └── *.svg              # Game assets
├── apprunner/             # App Runner deployment files
│   ├── apprunner-config.json
│   ├── deploy.sh
│   └── README-AppRunner.md
├── elasticbeanstalk/      # Elastic Beanstalk deployment files
│   ├── package.json
│   ├── server.js
│   ├── deploy-eb.sh
│   └── README-ElasticBeanstalk.md
└── README.md              # This file
```

## Deployment Options

### 1. AWS App Runner
- Deploys from GitHub repository
- Requires GitHub connection setup
- See `apprunner/README-AppRunner.md`

### 2. AWS Elastic Beanstalk  
- Deploys from local files (no GitHub auth needed)
- Uses Node.js + Express platform
- See `elasticbeanstalk/README-ElasticBeanstalk.md`

## Application Details
- **Framework**: AngularJS 1.8.3
- **UI**: Bootstrap 5.3.2
- **Version**: 3.0 (Updated 2024)
- **Type**: Single Page Application (SPA)

## Quick Start
1. Choose deployment method (App Runner or Elastic Beanstalk)
2. Follow instructions in respective README files
3. Deploy and test your Space Invaders game!