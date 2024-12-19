import React, { useState } from "react";
// import { withdrawFund } from "../utils/contractServices";
import { depositUSDC } from "../utils/services";
import { toast } from "react-toastify";

function ContractActions() {
  const [depositValue, setDepositValue] = useState("");

  const handleDeposit = async () => {
    try {
      await depositUSDC(depositValue);
    } catch (error) {
      toast.error(error?.reason);
    }
    setDepositValue("");
  };

  const handleWithdraw = async () => {
    try {
      // await withdrawFund();
      console.log("Withdraw Funds");
    } catch (error) {
      toast.error(error?.reason);
    }
  };

  return (
    <div>
      <h2>Contract Actions</h2>
      <div>
        <input
          type="text"
          value={depositValue}
          onChange={(e) => setDepositValue(e.target.value)}
          placeholder="Amount in USDC"
        />
        <button onClick={handleDeposit}>Deposit Funds</button>
      </div>
      <br />
      <div>
        <button onClick={handleWithdraw}>Withdraw Funds</button>
      </div>
    </div>
  );
}

export default ContractActions;