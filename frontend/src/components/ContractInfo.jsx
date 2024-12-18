import React, { useState, useEffect } from 'react';
import { getBalances } from '../utils/services';

function ContractInfo({ account }) {
  const [balances, setBalances] = useState({
    freeBalance: null,
    reservedBalance: null,
    totalBalance: null,
  });

  useEffect(() => {
    const fetchBalances = async () => {
      const accountBalances = await getBalances(account);
      if (accountBalances) {
        setBalances(accountBalances);
      }
    };
    fetchBalances();
  }, [account]);

  return (
    <div>
      <h2>Contract Balances</h2>
      <p>Free Balance: {balances.freeBalance} USDC</p>
      <p>Reserved Balance: {balances.reservedBalance} USDC</p>
      <p>Total Balance: {balances.totalBalance} USDC</p>
      <p>Connected Account: {account}</p>
    </div>
  );
}

export default ContractInfo;