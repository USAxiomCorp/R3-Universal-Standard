# R³ Truth Chain — Deployment Instructions
## Polygon Mainnet via Remix IDE

---

## Step 1: Open Remix

Go to: **remix.ethereum.org**

---

## Step 2: Create the Contract File

1. In the File Explorer (left panel) click the **+** icon
2. Name the file: `R3TruthChain.sol`
3. Paste the entire contents of `R3TruthChain.sol` into the editor

---

## Step 3: Compile

1. Click the **Solidity Compiler** tab (second icon, left panel)
2. Select compiler version: **0.8.19**
3. Click **Compile R3TruthChain.sol**
4. Green checkmark = success

---

## Step 4: Connect MetaMask to Polygon Mainnet

In MetaMask:
```
Network name:    Polygon Mainnet
RPC URL:         https://polygon-rpc.com
Chain ID:        137
Currency symbol: MATIC
Block explorer:  https://polygonscan.com
```

Make sure you have MATIC for gas. Deployment costs approximately 0.01–0.05 MATIC.

---

## Step 5: Deploy

1. Click the **Deploy & Run Transactions** tab (third icon)
2. Environment: select **Injected Provider - MetaMask**
3. MetaMask will connect — confirm
4. Contract: select **R3TruthChain**
5. Click **Deploy**
6. MetaMask will ask to confirm — approve
7. Wait for transaction to confirm (~2 seconds on Polygon)

---

## Step 6: Save the Contract Address

After deployment Remix shows the deployed contract address.

**Copy this address immediately and save it.**

```
R3TruthChain deployed at: 0x[YOUR_CONTRACT_ADDRESS]
```

This address goes in:
- The R³ Standard README
- Every primary document registered
- The trust score platform (if integrating)

---

## Step 7: Register Your First Fixed Point

In Remix under the deployed contract find `registerFixedPoint`.

Fill in the fields:

```
documentHash:   [SHA256 hash of your document as bytes32]
industry:       "materials"
fixedPoint:     "Simple cubic Pb at a=3.18A predicted Tc=295K"
iterationDepth: "10^15"
certaintyLevel: "Theoretical"
documentId:     "R3-SPEC-SC-01-20260315"
repositoryUrl:  "github.com/[username]/superconductor-predictions"
```

Click **transact**. Confirm in MetaMask. Done.

Your fixed point is now anchored in time on Polygon. Immutable. Queryable by anyone.

---

## How to Generate a bytes32 Hash in Python

```python
import hashlib

def file_to_bytes32(filepath):
    with open(filepath, 'rb') as f:
        content = f.read()
    hash_hex = hashlib.sha256(content).hexdigest()
    return '0x' + hash_hex

# Example
print(file_to_bytes32('SC-01_specification.pdf'))
```

Or for a string:

```python
def string_to_bytes32(text):
    hash_hex = hashlib.sha256(text.encode()).hexdigest()
    return '0x' + hash_hex
```

---

## Contract Functions — What Each Does

```
registerFixedPoint()
─────────────────────────────
Owner only.
Anchors a primary document on chain.
Call once per dossier or specification.


registerCertaintyBrief()
─────────────────────────────
Owner only.
Links a certainty brief to its primary.
Call once per brief per audience.


recordVerification()
─────────────────────────────
Anyone can call.
Records a verification result.
CONFIRM / DENY / INCONCLUSIVE.
All results accepted equally.


recordCorrection()
─────────────────────────────
Owner only.
Documents a self-correction.
R3 applied to R3.


verifyDocument()
─────────────────────────────
Anyone can call. Free (view function).
Checks if a hash is registered.
Returns industry, fixed point, certainty level, timestamp.
Any party can use this to verify authenticity.


getChainSummary()
─────────────────────────────
Anyone can call. Free.
Returns primary document + counts of
briefs, verifications, corrections.
One call shows everything.
```

---

## Verify on Polygonscan

After deployment go to:
`https://polygonscan.com/address/[YOUR_CONTRACT_ADDRESS]`

You can see:
- Every transaction
- Every registered fixed point
- Every verification result
- Every certainty brief
- Every correction

All public. All permanent. All free to query.

---

## Gas Costs (Approximate)

```
Deploy contract:          ~0.02 MATIC
registerFixedPoint:       ~0.003 MATIC
registerCertaintyBrief:   ~0.002 MATIC
recordVerification:       ~0.003 MATIC
recordCorrection:         ~0.002 MATIC
Read functions:           FREE (view calls)
```

Total to deploy and register one full fixed point
with two certainty briefs: approximately **0.03 MATIC**

At current MATIC prices: less than $0.02.

---

*CC0 1.0 Universal — Public Domain*  
*Advanceer IVS Labs — Universal Standard Axiom Corporation*
