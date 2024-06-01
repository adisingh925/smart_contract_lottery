# Decentralized Lottery System on Sepolia Testnet

Welcome to the Decentralized Lottery System project! This project leverages Solidity, Chainlink VRF 2.5, and Chainlink Price Feeds, developed using the Brownie framework, to create a fair and transparent lottery system on the Sepolia testnet.

## Table of Contents
- [Project Overview](#project-overview)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Deployment](#deployment)
- [Running the Lottery](#running-the-lottery)
- [Testing](#testing)
- [Technologies Used](#technologies-used)
- [Contributing](#contributing)
- [License](#license)

## Project Overview

This project implements a decentralized lottery system where participants can enter by paying a fee of Sepolia ETH worth $50. The winner is selected using Chainlink's VRF 2.5, ensuring a verifiable and tamper-proof random selection. The entry fee is dynamically calculated using Chainlink's AggregatorV3Interface to fetch the latest ETH-USD price.

## Features

- **Fairness:** Verifiable random selection of the winner using Chainlink VRF 2.5.
- **Transparency:** All transactions and processes are visible and verifiable on the blockchain.
- **Accuracy:** Real-time ETH-USD pricing ensures the entry fee is always $50 worth of ETH.
- **Reliability:** Comprehensive unit and integration tests to ensure robustness.

## Getting Started

### Prerequisites

- Python 3.7+
- Brownie
- Ganache (for local development)
- Sepolia ETH (for testnet deployment and participation)

### Installation

1. Clone the repository:

    ```bash
    git clone https://github.com/yourusername/lottery-system.git
    cd lottery-system
    ```

2. Install the required dependencies:

    ```bash
    pip install -r requirements.txt
    ```

3. Set up a `.env` file with your environment variables:

    ```plaintext
    WEB3_INFURA_PROJECT_ID=your_infura_project_id
    PRIVATE_KEY=your_private_key
    ```

## Deployment

1. Compile the smart contracts:

    ```bash
    brownie compile
    ```

2. Deploy the contracts to the Sepolia testnet:

    ```bash
    brownie run scripts/deploy.py --network sepolia
    ```

## Running the Lottery

Use the following commands to interact with the lottery:

1. **Deploy the Lottery:**

    ```python
    from scripts.deploy_lottery import deploy_lottery
    deploy_lottery()
    ```

2. **Start the Lottery:**

    ```python
    from scripts.start_lottery import start_lottery
    start_lottery()
    ```

3. **Enter the Lottery:**

    ```python
    from scripts.enter_lottery import enter_lottery
    enter_lottery()
    ```

4. **End the Lottery:**

    ```python
    from scripts.end_lottery import end_lottery
    end_lottery()
    ```

## Testing

Run the tests to ensure everything is working correctly:

```bash
brownie test
