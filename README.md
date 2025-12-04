# Kubernetes CI Load Testing Pipeline

This repository implements a complete **Kubernetes-based CI pipeline** that provisions a multi-node cluster, deploys workloads, runs HTTP ingress routing, performs load testing, and posts automated results back to the pull request.



---

# Architecture Overview

## The CI pipeline performs the following steps:

### 1 Create a multi-node Kind Kubernetes cluster

- 1 control plane

- 2 worker nodes

- Separate configs for macOS and CI

### 2 Deploy Kubernetes resources via Terraform

- Ingress-NGINX controller

- Two echo services (foo and bar)

- Ingress host-based routing:

- foo.localhost → foo service

- bar.localhost → bar service

### 3 Validate cluster health

- Kubernetes API readiness

- Deployment readiness

- Ingress existence

- Route validation via kubectl port-forward

### 4 Run Vegeta load testing

- Randomized traffic to both hosts

- Port-forward into ingress (CI-stable)

- JSON + Markdown report generation

### 5 Post results back to the PR

- GitHub Actions bot comments with metrics:

- Throughput

- Success rate

- Failure rate

- Latency (mean / p90 / p95)

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

---

# TIME TAKEN TO COMPLETE

Monday    1 Hour Research
Tuesday   1 Hour Intial installation of tools and Terraform coding
Wednesday 1 Hour Terraform coding and base files creating/Testing
Friday    30 Minutes Testing locally
Saturday  30 Minutes Debugging
Sunday    30 Minutes Debugging
Tuesday   30 Minutes Fix and completed