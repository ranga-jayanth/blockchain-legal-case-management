# Blockchain-Based Secure Legal Case Management (Educational Prototype)

A Solidity smart-contract prototype for registering legal case identifiers and tracking versions of document hashes. It demonstrates role-gated contract actions and tamper-evident change history; it is not production legal software.

> **Important safety note:** Never put client names, case details, document contents, personal data, or secrets on a public blockchain. Blockchain state is publicly observable even when Solidity variables or view functions are marked private/restricted. Store encrypted documents off-chain, and only consider anchoring a hash of the encrypted file after legal/security review.

## Features

- Owner-controlled grant and revoke of contract action permissions
- Register a random case identifier with an initial document hash
- Append new document-hash versions without overwriting history events
- Archive a case to stop further modifications
- Event logs for case creation, hash updates, access changes, and archival
- Hardhat tests for permissions, versions, and archived cases

## Stack

- Solidity 0.8.24
- Hardhat and Ethers.js
- Local Hardhat EVM for development and tests

## Run locally

Requires Node.js 20+.

```bash
npm install
npm test
npm run compile
npm run deploy:local
```

The local deployment prints a contract address for the temporary Hardhat network. For a persistent local chain, start `npx hardhat node` in one terminal and run `npm run deploy:localhost` in another.

## Contract workflow

1. The deployer becomes the owner and first authorized address.
2. The owner grants contract-call permissions to another wallet.
3. An authorized wallet registers a random `bytes32` case ID and a document hash.
4. Authorized users append a new hash when the encrypted off-chain document changes.
5. The owner can revoke access; an authorized user can archive the record.

## Security limits

- This is a learning/demo contract, not audited and not suitable for real legal matters.
- Access checks restrict contract functions; they do not make public-chain state confidential.
- Hashes can still reveal information through guessing or correlation. Use high-entropy random identifiers and assess disclosure risks before publishing any hash.
- A public chain has no private case file storage. Keep documents encrypted and off-chain, use proper key management, and obtain legal/security review before any real deployment.
- The prototype does not implement identity verification, court integrations, document encryption, key recovery, or jurisdiction-specific compliance.

## Attribution

This repository is an original educational implementation using the official Solidity and Hardhat documentation. It is not a copy of a third-party repository.

- https://docs.soliditylang.org/
- https://hardhat.org/docs
- https://docs.ethers.org/

## Next improvements

- Add a local-only web3.js interface for wallet connection and event history
- Add property-based and fuzz tests
- Add a deployment workflow for a local testnet and verification checklist
- Add a threat model and independent contract audit before any public testnet demo