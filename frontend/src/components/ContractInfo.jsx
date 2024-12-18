import React, { useEffect, useState } from "react";
import { getContractBalanceInETH } from "../utils/contractServices";
import { getBalances } from "../utils/services";

function ContractInfo({ account }) {
  const [balance, setBalance] = useState(null);

  useEffect(() => {
    const fetchBalance = async () => {
      const balanceInETH = await getContractBalanceInETH();
      setBalance(balanceInETH);
      console.log(getBalances(account));
    };
    fetchBalance();
  }, []);

  return (
    <div>
      <h2>Contract Balance: {balance} ETH</h2>
      <p>Connected Account: {account}</p>
    </div>
  );
}

export default ContractInfo;