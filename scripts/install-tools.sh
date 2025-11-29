#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Installing required tooling..."

sudo apt-get update -qq
sudo apt-get install -y -qq \
  curl \
  jq \
  apt-transport-https \
  ca-certificates

# ----------------------
# kubectl
# ----------------------
if ! command -v kubectl >/dev/null; then
  echo "📦 Installing kubectl..."
  curl -sSL https://dl.k8s.io/release/stable.txt | \
    xargs -I {} curl -sSL -o kubectl https://dl.k8s.io/release/{}/bin/linux/amd64/kubectl
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
else
  echo "✅ kubectl already installed"
fi

# ----------------------
# kind
# ----------------------
if ! command -v kind >/dev/null; then
  echo "📦 Installing kind..."
  curl -sLo kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
  chmod +x kind
  sudo mv kind /usr/local/bin/
else
  echo "✅ kind already installed"
fi

# ----------------------
# Terraform
# ----------------------
if ! command -v terraform >/dev/null; then
  echo "📦 Installing Terraform..."
  curl -sLo terraform.zip https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
  unzip -qq terraform.zip
  chmod +x terraform
  sudo mv terraform /usr/local/bin/
  rm terraform.zip
else
  echo "✅ Terraform already installed"
fi

# ----------------------
# Helm
# ----------------------
if ! command -v helm >/dev/null; then
  echo "📦 Installing Helm..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
  echo "✅ Helm already installed"
fi

# ----------------------
# Vegeta
# ----------------------
if ! command -v vegeta >/dev/null; then
  echo "📦 Installing Vegeta..."
  curl -sLo vegeta.tar.gz https://github.com/tsenart/vegeta/releases/download/v12.11.1/vegeta_12.11.1_linux_amd64.tar.gz
  tar -xzf vegeta.tar.gz
  sudo mv vegeta /usr/local/bin/
  rm vegeta.tar.gz
else
  echo "✅ Vegeta already installed"
fi

echo "✅ All tools successfully installed"
