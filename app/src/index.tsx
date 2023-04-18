import "@rainbow-me/rainbowkit/styles.css";
import React from "react";
import ReactDOM from "react-dom";
import App from "./App";

import { getDefaultWallets, RainbowKitProvider } from "@rainbow-me/rainbowkit";
import { configureChains, createClient, WagmiConfig } from "wagmi";
import { mainnet, polygon, optimism, arbitrum } from "wagmi/chains";
import { alchemyProvider } from "wagmi/providers/alchemy";
import { publicProvider } from "wagmi/providers/public";

const { chains, provider } = configureChains(
  [mainnet, polygon, optimism, arbitrum],
  [
    alchemyProvider({ apiKey: import.meta.env.VITE_ALCKEMY_KEY }),
    publicProvider(),
  ]
);

const { connectors } = getDefaultWallets({
  appName: "Merkle Shaman",
  projectId: "YOUR_PROJECT_ID",
  chains,
});

const wagmiClient = createClient({
  autoConnect: true,
  connectors,
  provider,
});

ReactDOM.render(
  <React.StrictMode>
    <WagmiConfig client={wagmiClient}>
      <RainbowKitProvider chains={chains}>
        <App />
      </RainbowKitProvider>
    </WagmiConfig>
  </React.StrictMode>,
  document.getElementById("root")
);
