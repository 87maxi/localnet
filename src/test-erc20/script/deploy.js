const { ethers } = require("ethers");
const fs = require("fs");
const path = require("path");

// Set the JSON-RPC endpoint URL (e.g. localnet:8545)
const jsonRpcUrl = "http://localhost:8545";

// Set the private key for deployment
const privateKey = fs.readFileSync("./privatekey.txt", "utf8");

// Set the contract metadata
const contractName = "ERC20Token";
const contractPath = path.join(__dirname, "../out/ERC20Token.json");

async function deploy() {
  // Create a new provider instance
  const provider = new ethers.providers.JsonRpcProvider(jsonRpcUrl);

  // Create a new wallet instance
  const wallet = new ethers.Wallet(privateKey, provider);

  // Load the contract ABI and bytecode
  const contractMetadata = JSON.parse(fs.readFileSync(contractPath, "utf8"));
  const abi = contractMetadata.abi;
  const bytecode = contractMetadata.bytecode;

  // Deploy the contract
  const contractFactory = new ethers.ContractFactory(abi, bytecode, wallet);
  const contract = await contractFactory.deploy("MyToken", "MTK", 1000);
  await contract.deployed();

  console.log(`Contract deployed to: ${contract.address}`);
}

deploy();