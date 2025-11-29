# ----------------------------
# Variables
# ----------------------------
KIND_CLUSTER_NAME ?= local-test
KIND_CONFIG        ?= kind/kind-config-macos.yaml
TF_DIR             ?= terraform

# ----------------------------
# Create Kind cluster + apply Terraform
# ----------------------------
local-up:
	@echo "🔧 Creating Kind cluster ($(KIND_CLUSTER_NAME))..."
	kind create cluster --name $(KIND_CLUSTER_NAME) --config $(KIND_CONFIG)
	@echo "🔧 Configuring kubeconfig..."
	kind get kubeconfig --name $(KIND_CLUSTER_NAME) > $$HOME/.kube/config
	@echo "📦 Applying Terraform..."
	cd $(TF_DIR) && terraform init && terraform apply -auto-approve
	@echo "🎉 Local cluster is up!"

# ----------------------------
# Run readiness checks + load test
# ----------------------------
local-test:
	@echo "🔍 Running readiness checks..."
	chmod +x scripts/wait-for-ready.sh
	./scripts/wait-for-ready.sh
	@echo "📈 Running load test..."
	chmod +x scripts/run-loadtest.sh
	./scripts/run-loadtest.sh
	@echo "🎉 Local test complete!"

# ----------------------------
# Simulate CI run locally
# ----------------------------
ci-test: destroy
	@echo "🔧 Simulating CI workflow locally..."
	make local-up
	make local-test
	@echo "🎉 CI test simulation complete!"

# ----------------------------
# Destroy TF resources + Kind cluster
# ----------------------------
destroy:
	@echo "🧹 Destroying Terraform resources..."
	@if [ -d "$(TF_DIR)" ]; then cd $(TF_DIR) && terraform destroy -auto-approve || true; fi
	@echo "🗑️ Deleting Kind cluster..."
	kind delete cluster --name $(KIND_CLUSTER_NAME) || true
	@echo "🧼 Clean environment ready."

# ----------------------------
# Full rebuild (destroy + local-up)
# ----------------------------
rebuild: destroy local-up
