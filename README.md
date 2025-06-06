# Blockchain GPU Manager

A decentralized GPU resource management and approval system built on the Ethereum blockchain for laboratory environments.

## Features

- **Decentralized Approval**: Professors approve or reject GPU borrowing requests on-chain; records are immutable and transparent.
- **User-Friendly Interface**: Students can submit GPU requests using blockchain wallets (e.g., MetaMask, Remix).
- **Role-Based Permissions**: Only authorized professor addresses can approve/reject; all approvals are traceable.
- **Pending Requests View**: Professors can query all pending requests for easy management.
- **On-chain Event Logging**: All actions (apply, approve, reject) emit events for easy off-chain monitoring and notification integration.
- **Extensible**: Easily integrable with off-chain notification systems (e.g., email, Slack, LINE) via event listeners.

## How It Works

1. **Students** submit a GPU request (including details, GPU index, target machine) via the smart contract.
2. **Professors** review pending requests and approve/reject them on-chain.
3. **All records** are stored on the Ethereum testnet (e.g., Sepolia), ensuring transparency and tamper-resistance.
4. (Optional) **Off-chain scripts** can listen to approval/rejection events and send notifications to users.

## Quick Start

### 1. Clone
```bash
git clone https://github.com/madiba-riddim/gpu-manager-blockchain.git
cd gpu-manager-blockchain
```
### 2. Build & Test

```bash
forge build
forge test
```

### 3. Deploy to Testnet
Set your .env file in the project root:
```bash
RPC_URL=https://eth-sepolia.g.alchemy.com/v2/your-alchemy-key
PRIVATE_KEY=your-testnet-account-private-key
```
Deploy using Foundry:
```bash
forge script script/Deploy.s.sol:DeployScript --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

### 4. Interact
1. Interact with Contract
Use Remix + MetaMask to interact with the contract on Sepolia testnet.

Import the contract address and ABI, or use Etherscan after verifying the contract source code.
```bash
Directory Structure
.
|-- README.md
|-- LICENSE
|-- foundry.toml
|-- .gitignore
|-- src
|   |-- gpu.sol
|-- test
|   |-- GPUApproval.t.sol
|-- script
|   |-- Deploy.s.sol
|-- lib
    |-- (dependencies)

```
## Demo
This demo showcases how to interact with the deployed contract on the Sepolia testnet using the REMIX IDE. The contract is deployed from the professor’s address. A student’s address is then used to submit a GPU borrowing request. The video demonstrates that if a student attempts to approve or reject a request, the transaction fails as expected due to permission restrictions. In contrast, when the professor’s address is used to approve or reject requests, the transactions succeed and the number of pending requests decreases accordingly.
[![Watch the demo](https://img.youtube.com/vi/c1HIq_Pg5Wc/0.jpg)](https://youtu.be/c1HIq_Pg5Wc?feature=shared)

## Security & License
Do not commit your .env file or private keys!

This project is for educational and research purposes.

Licensed under the MIT License.

## Acknowledgements
Built with Foundry, and Solidity.

Inspired by resource management needs in academic/research labs.

