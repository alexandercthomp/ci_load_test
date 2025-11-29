# Kubernetes CI Load Testing Pipeline

This repository implements a complete **Kubernetes-based CI pipeline** that provisions a multi-node cluster, deploys workloads, runs HTTP ingress routing, performs load testing, and posts automated results back to the pull request.

---

# 🚀 Features

### ✔ Kind multi-node Kubernetes cluster (CI & Local)
- 1 control-plane + 2 worker nodes  
- Configurable cluster for macOS (port mappings)  
- CI version uses Linux defaults

### ✔ Terraform-managed Kubernetes deployment
- Deploys:
  - Ingress-NGINX
  - `foo` http-echo deployment
  - `bar` http-echo deployment
  - Ingress routing (`foo.localhost`, `bar.localhost`)

### ✔ End-to-end CI pipeline (GitHub Actions)
- Spins up cluster
- Applies Terraform
- Waits for workload readiness
- Runs Vegeta load testing
- Posts results directly to the PR

### ✔ Local testing workflow (macOS + Docker)
- Separate Kind config for macOS networking
- Makefile helpers for easy testing


---

# 🧪 Local Testing (macOS)

Local testing uses **Kind** with a special macOS config (port mappings for ingress and Prometheus).

---

## 1. Install local dependencies

brew install kind kubectl terraform helm vegeta jq


## 2. Create the Kind cluster (macOS)
make local-up

This will:

Create Kind cluster with kind-config-macos.yaml

Apply Terraform

Deploy ingress + workloads

## 3. Wait for workloads & run load test
make local-test

This will:

Run scripts/wait-for-ready.sh

Run scripts/run-loadtest.sh

Generate:

loadtest-results/results.md

loadtest-results/results.json

## 4. Destroy local environment
make destroy

This will:

Destroy Terraform-managed Kubernetes resources

Delete the Kind cluster

Clean your local environment