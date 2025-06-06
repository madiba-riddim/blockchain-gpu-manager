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
## Contract Function Usage

### For Students

- **applyGPU**
  - `function applyGPU(string detail, uint gpuIndex, string machine) returns (uint id)`
  - **Usage:**  
    Students use this function to submit a GPU borrowing request.  
    - `detail`: Reason or description for borrowing.
    - `gpuIndex`: The specific GPU number/index to request.
    - `machine`: The machine on which the GPU resides.
  - **Returns:**  
    The function returns a unique request ID for tracking the application.

- **getRequest**
  - `function getRequest(uint id) view returns (address requester, string detail, Status status, uint gpuIndex, string machine, string rejectReason)`
  - **Usage:**  
    Any user (including students) can query details and the current status of a specific request by its ID.

- **getPendingRequestIds**
  - `function getPendingRequestIds() view returns (uint[] ids)`
  - **Usage:**  
    Lists all currently pending (unapproved) request IDs. Useful for users to check their application is in the queue.

---

### For Professors

- **approve**
  - `function approve(uint id)`
  - **Usage:**  
    Approves a pending GPU borrowing request.  
    - Only the professor's address can call this function.  
    - The request status is updated to "Approved" and removed from the pending list.

- **reject**
  - `function reject(uint id, string reason)`
  - **Usage:**  
    Rejects a pending request, with an optional reason for rejection.  
    - Only the professor's address can call this function.  
    - The request status is updated to "Rejected" with the rejection reason recorded.

- **getPendingRequestIds**
  - `function getPendingRequestIds() view returns (uint[] ids)`
  - **Usage:**  
    Professors can use this function to get a list of all pending requests that need review.

- **getRequest**
  - `function getRequest(uint id) view returns (address requester, string detail, Status status, uint gpuIndex, string machine, string rejectReason)`
  - **Usage:**  
    Professors can view full details of any request before making an approval or rejection decision.
    
- **pendingCount**
  - `pendingCount` (public uint)
  - **Usage:**  
    Returns the current number of pending (unapproved) requests in the system.

- **requestCount**
  - `requestCount` (public uint)
  - **Usage:**  
    Returns the total number of requests that have ever been submitted (regardless of status).

- **professor**
  - `professor` (public address)
  - **Usage:**  
    Returns the Ethereum address that is authorized to approve or reject requests (the current professor).

---

**Note:**  
- Only the professor’s address can approve or reject requests.  
- All actions are permanently recorded on-chain for transparency and auditability.

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

