# Makefile for VeriVote Foundry Project
-include .env

# === CONFIGURATION ===
RPC_URL           ?= http://localhost:8545
PRIVATE_KEY       ?= your_private_key_here
ETHERSCAN_API_KEY ?= your_etherscan_api_key_here
DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# RPCs
SEPOLIA_RPC_URL   ?= https://sepolia.infura.io/v3/your_project_id
MAINNET_RPC_URL   ?= https://mainnet.infura.io/v3/your_project_id
POLYGON_RPC_URL   ?= https://polygon-rpc.com
ZKSYNC_RPC_URL    ?= https://mainnet.era.zksync.io

# === DEFAULT TARGET ===
default: help

# === SETUP ===
install:
	@echo "🔧 Installing Foundry libraries..."
	forge install openzeppelin/openzeppelin-contracts 
	forge install smartcontractkit/chainlink-brownie-contracts
	forge install transmissions11/solmate
	forge install foundry-rs/forge-std 

# === BUILD ===
build:
	@echo "🔨 Building smart contracts..."
	forge build

clean:
	@echo "🧹 Cleaning project..."
	forge clean

remove:
	rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

update:
	forge update

# === TESTING ===
test:
	@echo "🧪 Running tests..."
	forge test -vvv

gas:
	@echo "⛽ Gas report..."
	forge test --gas-report

fmt:
	forge fmt

lint:
	npx solhint 'src/**/*.sol'

size:
	forge build --sizes

# === DRY-RUN SCRIPT ===
script:
	forge script script/DeployElection.s.sol --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY)

# === DEPLOYMENTS ===

deploy-anvil:
	forge script script/DeployElection.s.sol --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast -vvvv

deploy-sepolia:
	forge script script/DeployElection.s.sol --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

deploy-mainnet:
	forge script script/DeployElection.s.sol --rpc-url $(MAINNET_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

deploy-polygon:
	forge script script/DeployElection.s.sol --rpc-url $(POLYGON_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

deploy-zksync:
	forge script script/DeployElection.s.sol --rpc-url $(ZKSYNC_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -vvvv

# === HELP ===
help:
	@echo ""
	@echo "🛠 VeriVote Makefile Commands"
	@echo "-----------------------------"
	@echo " install         - Install dependencies"
	@echo " build           - Build smart contracts"
	@echo " clean           - Clean build artifacts"
	@echo " test            - Run unit tests"
	@echo " gas             - Show gas usage report"
	@echo " fmt             - Format code"
	@echo " lint            - Run solhint"
	@echo " size            - Show contract sizes"
	@echo " script          - Dry-run deployment"
	@echo " deploy-anvil    - Deploy to local Anvil node"
	@echo " deploy-sepolia  - Deploy to Sepolia testnet"
	@echo " deploy-mainnet  - Deploy to Ethereum mainnet"
	@echo " deploy-polygon  - Deploy to Polygon mainnet"
	@echo " deploy-zksync   - Deploy to zkSync Era"
	@echo " help            - Show this menu"

.PHONY: install build clean test gas fmt lint size help update remove
