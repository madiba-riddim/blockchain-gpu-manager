# Blockchain GPU Manager

A decentralized GPU resource management, tokenized approval, and peer-to-peer trading system built on the Ethereum blockchain for laboratory environments.

## Features

- **Tokenized GPU Access**: GPU borrowing requests require spending GPUQ tokens (ERC20). Professors distribute or sell these tokens.
- **Deposit & Fairness**: Students pay a usage fee (by hour) plus a deposit. Professors can approve, refund, or forfeit deposits based on user behavior.
- **Peer-to-Peer Token Marketplace**: Users can sell extra GPUQ tokens for ETH; buyers and sellers interact directly on-chain.
- **Decentralized Approval**: All requests and actions are logged and immutable on-chain.
- **Role-Based Permissions**: Only authorized professors can approve/reject/refund/forfeit; students manage their own requests and tokens.
- **On-chain Event Logging**: All actions (apply, approve, reject, return, refund, forfeit, buy, sell) emit events for off-chain monitoring and notification.
- **Extensible**: Easily integrable with notification systems or web frontends; can be deployed on public or private Ethereum chains.

## How It Works

1. **Students** obtain GPUQ tokens from the professor or buy them on-chain from others.
2. To borrow a GPU, a student submits a request (specifying details, GPU index, machine, and hours) and pays the required fee plus a deposit (all in GPUQ tokens).
3. **Professors** review and approve or reject requests. Upon approval, students can return GPUs after usage. The professor decides to refund or forfeit deposits based on conduct.
4. **Marketplace**: Any user can list tokens for sale (specify quantity & price); buyers send ETH to buy directly from sellers.
5. **All actions** are recorded on the Ethereum testnet (e.g., Sepolia), ensuring full transparency and tamper-resistance.

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
forge script script/DeployToken.s.sol:DeployToken --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
forge script script/DeployApproval.s.sol:DeployApproval --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
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
|-- src/
|   |-- gpu.sol
|   |-- GPUQToken.sol
|-- test/
|   |-- GPUApproval.t.sol
|-- script/
|   |-- DeployToken.s.sol
|   |-- DeployApproval.s.sol
|-- lib/
    |-- (dependencies)

```
## Contract Function Usage

### For Students

| Function                 | Signature                                                                     | Purpose                                                                |
| ------------------------ | ----------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| **applyGPU**             | `applyGPU(string detail, uint gpuIndex, string machine, uint hour) → uint id` | Submit a borrowing request  •  pays *hour × price* + *deposit*         |
| **returnGPU**            | `returnGPU(uint id)`                                                          | After finishing, call to mark the GPU as returned                      |
| **getRequest**           | `getRequest(uint id) view`                                                    | View full details and status of a specific request                     |
| **getPendingRequestIds** | `getPendingRequestIds() view → uint[]`                                        | List all request IDs that are still pending                            |
| **listForSale**          | `listForSale(uint tokenCount, uint pricePerTokenWei)`                         | Offer *tokenCount* GPUQ tokens for sale at a fixed ETH price per token |
| **buy**                  | `buy(uint saleId) payable`                                                    | Purchase a listed sale; send the required ETH with the call            |
| **GPUQToken (ERC-20)**   | *transfer*, *approve*, *allowance*, *balanceOf*, …                            | Standard token operations for moving or approving GPUQ                 |


---

### For Professors

| Function                                    | Signature                                             | Purpose                                                |
| ------------------------------------------- | ----------------------------------------------------- | ------------------------------------------------------ |
| **approve / reject**                        | `approve(uint id)` · `reject(uint id, string reason)` | Accept or decline a pending request                    |
| **refundDeposit**                           | `refundDeposit(uint id)`                              | Return the student’s deposit after a proper return     |
| **forfeitDeposit**                          | `forfeitDeposit(uint id)`                             | Confiscate the deposit if rules are violated           |
| **getRequest / getPendingRequestIds**       | *view methods*                                        | Review any single request or the list of pending ones  |
| **pendingCount / requestCount / professor** | public variables                                      | Inspect live contract statistics and professor address |

---

**Note:**  
- Only the professor can approve, reject, refund, or forfeit deposits.
- Every action—including token trades—is permanently and transparently recorded on-chain.

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

