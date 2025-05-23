# 🧠 STX-Predict

**STX-Predict** is a decentralized prediction market smart contract built on the [Stacks blockchain](https://www.stacks.co/) using the [Clarity](https://docs.stacks.co/write-smart-contracts/clarity-language) smart contract language. It allows users to create and participate in binary outcome events by staking STX tokens on predicted outcomes.

---

## 🚀 Features

- **Create Prediction Events**  
  Register a new prediction event with a unique event ID, description, and an assigned oracle to resolve it.

- **Stake on Outcomes**  
  Users can place bets on `yes` or `no` outcomes by staking STX.

- **Oracle-Based Resolution**  
  Only the pre-assigned oracle can finalize an event by submitting the correct outcome.

- **Reward Distribution**  
  Users who bet correctly can claim their proportional share of the STX pool.

- **Transparent & Immutable**  
  All actions and funds are governed by the smart contract, ensuring fairness and transparency.

---

## 📜 Smart Contract Functions

| Function | Description |
|----------|-------------|
| `create-event` | Initializes a new prediction event. |
| `place
