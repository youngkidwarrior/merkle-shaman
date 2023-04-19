const fs = require("fs");
const solc = require("solc");

const contractPath = "../src/MerkleDropShaman.sol";
const source = fs.readFileSync(contractPath, "utf8");

const input = {
  language: "Solidity",
  sources: {
    "MerkleDropShaman.sol": {
      content: source,
    },
  },
  settings: {
    outputSelection: {
      "*": {
        "*": ["abi", "evm.bytecode"],
      },
    },
  },
};

const output = JSON.parse(solc.compile(JSON.stringify(input)));

if (output.errors) {
  console.error("Compilation errors:");
  console.error(output.errors);
  process.exit(1);
}

const contractOutput =
  output.contracts["MerkleDropShaman.sol"].MerkleDropShaman;
const abi = contractOutput.abi;
const bytecode = contractOutput.evm.bytecode.object;

const contractJson = {
  abi: abi,
  bytecode: bytecode,
};

fs.writeFileSync(
  "./contracts/MerkleDropShaman.json",
  JSON.stringify(contractJson, null, 2)
);

console.log("ABI and bytecode saved to MerkleDropShaman.json successfully.");
