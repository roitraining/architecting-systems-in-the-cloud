# eksctl Installation Scripts

Scripts to install eksctl on different operating systems.

## Usage

### Linux (including AWS CloudShell)
```bash
chmod +x install-linux.sh
./install-linux.sh
```

### Windows PowerShell (Run as Administrator)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install-windows.ps1
```

### macOS
```bash
chmod +x install-macos.sh
./install-macos.sh
```

## Verification

After installation, verify eksctl is working:
```bash
eksctl version
```

## Prerequisites

- **Linux/macOS**: curl, tar, sudo access
- **Windows**: PowerShell (Run as Administrator)
- **macOS**: Optionally Homebrew for easier installation

## What is eksctl?

eksctl is the official CLI tool for Amazon EKS. It simplifies:
- Creating EKS clusters
- Managing node groups
- Configuring cluster add-ons
- Setting up IAM roles and policies

## Next Steps

After installing eksctl, you can create an EKS cluster:
```bash
cd ../kubernetes
eksctl create cluster -f create-cluster.yaml
```