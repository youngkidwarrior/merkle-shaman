import React, { useEffect, useState } from "react";
import { ethers } from "ethers";
import MerkleDropShamanArtifact from "../contracts/MerkleDropShaman.json";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useSigner, useContract } from "wagmi";

const App: React.FC = () => {
  const [provider, setProvider] = useState<ethers.providers.Web3Provider>();
  const [contract, setContract] = useState<ethers.Contract>();
  const [inputAddress, setInputAddress] = useState("");
  const [merkleRoot, setMerkleRoot] = useState("");
  const [claimPeriod, setClaimPeriod] = useState("");
  const [claimAmount, setClaimAmount] = useState("");
  const [claimMerkleProof, setClaimMerkleProof] = useState("");

  const { data: signer, isError, isLoading } = useSigner();

  const handleExistingContract = async () => {
    if (!provider || !inputAddress) return;

    try {
      const existingContract = useContract({
        address: inputAddress,
        abi: MerkleDropShamanArtifact.abi,
      });
      setContract(existingContract);
    } catch (error) {
      console.error("Error connecting to existing contract:", error);
    }
  };

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
      signer as ethers.Signer
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

  const handleAddPeriod = async () => {
    if (!contract || !merkleRoot) return;

    try {
      const tx = await contract.addPeriod(merkleRoot);
      await tx.wait();
      alert("Period added successfully!");
    } catch (error) {
      console.error("Error adding period:", error);
    }
  };

  const handleClaim = async () => {
    if (!contract || !claimPeriod || !claimAmount || !claimMerkleProof) return;

    try {
      const merkleProofArray = JSON.parse(claimMerkleProof);
      const tx = await contract.claim(
        claimPeriod,
        claimAmount,
        merkleProofArray
      );
      await tx.wait();
      alert("Claimed successfully!");
    } catch (error) {
      console.error("Error claiming:", error);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-black via-red-900 to-yellow-500">
      <div className="container mx-auto py-10 px-4">
        <h1 className="text-4xl text-white mb-8">Merkle Drop Shaman</h1>
        <ConnectButton />

        {!contract && (
          <form onSubmit={deployContract} className="grid grid-cols-2 gap-4">
            <label className="text-white">
              DAO Address:
              <input
                type="text"
                name="daoAddress"
                required
                className="block w-full mt-1 bg-gray-800 rounded text-white shadow-md"
              />
            </label>
            <label className="text-white">
              Period Length (in seconds):
              <input
                type="number"
                name="periodLengthInSeconds"
                required
                className="block w-full mt-1 bg-gray-800 rounded text-white shadow-md"
              />
            </label>
            <label className="text-white">
              Start Time (in seconds):
              <input
                type="number"
                name="startTimeInSeconds"
                required
                className="block w-full mt-1 bg-gray-800 rounded text-white shadow-md"
              />
            </label>
            <label className="text-white">
              Total Tokens to Drop:
              <input
                type="number"
                name="totalTokensToDrop"
                required
                className="block w-full mt-1 bg-gray-800 rounded text-white shadow-md"
              />
            </label>
            <label className="text-white">
              Should Drop Shares:
              <select
                name="shouldDropShares"
                required
                className="block w-full mt-1 bg-gray-800 rounded text-white shadow-md"
              >
                <option value="true">Yes</option>
                <option value="false">No</option>
              </select>
            </label>
            <label className="text-white">
              Should Drop Loot:
              <select
                name="shouldDropLoot"
                required
                className="block w-full mt-1 bg-gray-800 rounded text-white shadow-md"
              >
                <option value="true">Yes</option>
                <option value="false">No</option>
              </select>
            </label>
            <label className="text-white">
              Custom Token Address (optional):
              <input
                type="text"
                name="customToken"
                className="block w-full mt-1 bg-gray-800 rounded text-white shadow-md"
              />
            </label>
            <button
              type="submit"
              className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 col-span-2 shadow-md"
            >
              Deploy Contract
            </button>
            <label className="text-white col-span-2">
              Existing Contract Address (optional):
              <input
                type="text"
                value={inputAddress}
                onChange={(e) => setInputAddress(e.target.value)}
                className="block w-full mt-1 bg-gray-800 rounded text-white shadow-md"
              />
            </label>
            <button
              type="button"
              onClick={handleExistingContract}
              className="bg-red-800 text-white px-4 py-2 rounded hover:bg-red-900 col-span-2 shadow-md"
            >
              Connect to Existing Contract
            </button>
          </form>
        )}
        {contract && (
          <div className="bg-gray-800 text-white p-6 rounded shadow-md mt-8">
            <h2 className="text-2xl mb-4">Contract Deployed</h2>
            <p className="mb-4">
              Address: <span className="font-mono">{contract.address}</span>
            </p>
            <div className="mb-8">
              <h3 className="text-xl mb-2">Add Period</h3>
              <label className="block mb-2">
                Merkle Root:
                <input
                  type="text"
                  value={merkleRoot}
                  onChange={(e) => setMerkleRoot(e.target.value)}
                  className="block w-full mt-1 bg-gray-700 rounded text-white shadow-md"
                />
              </label>
              <button
                onClick={handleAddPeriod}
                className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 shadow-md"
              >
                Add Period
              </button>
            </div>
            <div>
              <h3 className="text-xl mb-2">Claim</h3>
              <label className="block mb-2">
                Period:
                <input
                  type="number"
                  value={claimPeriod}
                  onChange={(e) => setClaimPeriod(e.target.value)}
                  className="block w-full mt-1 bg-gray-700 rounded text-white shadow-md"
                />
              </label>
              <label className="block mb-2">
                Amount:
                <input
                  type="number"
                  value={claimAmount}
                  onChange={(e) => setClaimAmount(e.target.value)}
                  className="block w-full mt-1 bg-gray-700 rounded text-white shadow-md"
                />
              </label>
              <label className="block mb-2">
                Merkle Proof (JSON Array):
                <input
                  type="text"
                  value={claimMerkleProof}
                  onChange={(e) => setClaimMerkleProof(e.target.value)}
                  className="block w-full mt-1 bg-gray-700 rounded text-white shadow-md"
                />
              </label>
              <button
                onClick={handleClaim}
                className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 shadow-md"
              >
                Claim
              </button>
            </div>
            {/* Add input fields and buttons for claimAll and recover */}
          </div>
        )}
      </div>
    </div>
  );
};

export default App;
