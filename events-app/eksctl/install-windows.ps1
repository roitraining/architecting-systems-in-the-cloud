# Install eksctl on Windows PowerShell

Write-Host "Installing eksctl for Windows..." -ForegroundColor Green

# Create temp directory
$tempDir = "$env:TEMP\eksctl"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# Download eksctl
$url = "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Windows_amd64.zip"
$zipFile = "$tempDir\eksctl.zip"

Write-Host "Downloading eksctl..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $url -OutFile $zipFile

# Extract
Write-Host "Extracting..." -ForegroundColor Yellow
Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force

# Move to Program Files
$installDir = "$env:ProgramFiles\eksctl"
New-Item -ItemType Directory -Path $installDir -Force | Out-Null
Copy-Item "$tempDir\eksctl.exe" -Destination "$installDir\eksctl.exe" -Force

# Add to PATH (requires admin)
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
if ($currentPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$installDir", "Machine")
    Write-Host "Added to system PATH. Restart PowerShell to use eksctl." -ForegroundColor Green
}

# Clean up
Remove-Item $tempDir -Recurse -Force

Write-Host "eksctl installed successfully!" -ForegroundColor Green
Write-Host "Run 'eksctl version' to verify (after restarting PowerShell)" -ForegroundColor Yellow