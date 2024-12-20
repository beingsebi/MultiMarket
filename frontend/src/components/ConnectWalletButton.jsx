import React from "react";
import {requestAccount} from "../utils/services";
import EventEmitter from "../utils/EventEmitter";

function ConnectWalletButton({ setAccount }) {
  const connectWallet = async () => {
    try {
      const account = await requestAccount();
      setAccount(account);
      EventEmitter.emit("accountChanged", account);
    } catch (error) {
      console.error("Failed to connect wallet:", error);
    }
  };

  return <button onClick={connectWallet}>Connect Web3 Wallet</button>;
}

export default ConnectWalletButton;