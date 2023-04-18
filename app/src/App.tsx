import React, { useEffect, useState } from "react";
import { ethers } from "ethers";
import MerkleDropShamanArtifact from "../../artifacts/src_MerkleDropShaman_sol_MerkleDropShaman.json";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useSigner } from "wagmi";

const App: React.FC = () => {
  const [provider, setProvider] = useState<ethers.providers.Web3Provider>();
  const [contract, setContract] = useState<ethers.Contract>();
  const { data: signer, isError, isLoading } = useSigner();

  const deployContract = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    const formData = new FormData(event.currentTarget);
    const daoAddress = formData.get("daoAddress") as string;
    const periodLengthInSeconds = Number(formData.get("periodLengthInSeconds"));
    const startTimeInSeconds = Number(formData.get("startTimeInSeconds"));
    const totalTokensToDrop = Number(formData.get("totalTokensToDrop"));
    const shouldDropShares = formData.get("shouldDropShares") === "true";
    const shouldDropLoot = formData.get("shouldDropLoot") === "true";
    const customToken = formData.get("customToken") as string;

    if (!provider) return;
    const factory = new ethers.ContractFactory(
      MerkleDropShamanArtifact.abi,
      MerkleDropShamanArtifact.bytecode,
      signer
    );

    const deployedContract = await factory.deploy(
      daoAddress,
      periodLengthInSeconds,
      startTimeInSeconds,
      totalTokensToDrop,
      shouldDropShares,
      shouldDropLoot,
      customToken
    );

    await deployedContract.deployed();
    setContract(deployedContract);
  };

  return (
    <div>
      <h1>Merkle Drop Shaman</h1>
      <ConnectButton />
      {!contract && (
        <form onSubmit={deployContract}>
          <label>
            DAO Address:
            <input type="text" name="daoAddress" required />
          </label>
          <label>
            Period Length (in seconds):
            <input type="number" name="periodLengthInSeconds" required />
          </label>
          <label>
            Start Time (in seconds):
            <input type="number" name="startTimeInSeconds" required />
          </label>
          <label>
            Total Tokens to Drop:
            <input type="number" name="totalTokensToDrop" required />
          </label>
          <label>
            Should Drop Shares:
            <select name="shouldDropShares" required>
              <option value="true">Yes</option>
              <option value="false">No</option>
            </select>
          </label>
          <label>
            Should Drop Loot:
            <select name="shouldDropLoot" required>
              <option value="true">Yes</option>
              <option value="false">No</option>
            </select>
          </label>
          <label>
            Custom Token Address (optional):
            <input type="text" name="customToken" />
          </label>
          <button type="submit">Deploy Contract</button>
        </form>
      )}
      {contract && (
        <div>
          <h2>Contract Deployed</h2>
          <p>Address: {contract.address}</p>
        </div>
      )}
    </div>
  );
};

export default App;
