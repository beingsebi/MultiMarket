import React, { useState, useEffect } from "react";
import { BrowserRouter as Router, Route, Routes } from "react-router-dom";

import ConnectWalletButton from "./components/ConnectWalletButton";
import ContractInfo from "./components/ContractInfo";
import MMEvents from "./components/MMEvents";
import MMEvent from "./components/MMEvent";
import ContractActions from "./components/ContractActions";
import {requestAccount} from "./utils/services";
import { ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import EventEmitter from "./utils/EventEmitter";

function App() {
  const [account, setAccount] = useState(null);

  useEffect(() => {
    const fetchCurAccount = async () => {
      const account = await requestAccount();
      setAccount(account);
      EventEmitter.emit("accountChanged", account);
    };
    fetchCurAccount();
  }, []);

  useEffect(() => {
    const handleAccountChanged = (newAccounts) => {
      const newAccount = newAccounts.length > 0 ? newAccounts[0] : null;
      setAccount(newAccount);
      EventEmitter.emit("accountChanged", newAccount);
    };
    if (window.ethereum) {
      window.ethereum.on("accountsChanged", handleAccountChanged);
    }
    return () => {
      window.ethereum?.removeListener("accountsChanged", handleAccountChanged);
    };
  });

  return (
    <Router>
      <ToastContainer />
      <Routes>
        <Route
          path="/"
          element={
            !account ? (
              <ConnectWalletButton setAccount={setAccount} />
            ) : (
              <React.Fragment>
                <div className="contract-interactions">
                  <ContractInfo account={account} />
                  <ContractActions />
                </div>
                <MMEvents />
              </React.Fragment>
            )
          }
        />
        <Route path="/event/:eventIndex" element={<MMEvent />} />
      </Routes>
    </Router>
  );
}

export default App;