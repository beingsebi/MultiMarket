import React, { useState } from "react";
import { depositUSDC, withdrawUSDC } from "../utils/services";
import { toast } from "react-toastify";

function ContractActions() {
  const [depositValue, setDepositValue] = useState("");
  const [withdrawValue, setWithdrawValue] = useState("");

  const handleDeposit = async () => {
    const error = await depositUSDC(depositValue);
    if (error) {
      toast.error(error?.reason || "An unexpected error occurred");
    }
    setDepositValue("");
  };

  const handleWithdraw = async () => {
    const error = await withdrawUSDC(withdrawValue);
    if (error) {
      toast.error(error?.reason || "An unexpected error occurred");
    }
    setWithdrawValue("");
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
        <input
          type="text"
          value={withdrawValue}
          onChange={(e) => setWithdrawValue(e.target.value)}
          placeholder="Amount in USDC"
        />
        <button onClick={handleWithdraw}>Withdraw Funds</button>
      </div>
    </div>
  );
}

export default ContractActions;