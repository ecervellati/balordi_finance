import { useState, useEffect, useCallback } from 'react';

const BASE_URL = process.env.REACT_APP_API_URL || "http://localhost:4005";

export function useBankLogic() {
  const [accounts, setAccounts] = useState([]);
  const [status, setStatus] = useState("READY");

  const fetchAccounts = useCallback(async () => {
    try {
      const response = await fetch(`${BASE_URL}/accounts`);
      const data = await response.json();
      setAccounts(data.sort((a, b) => a.iban.localeCompare(b.iban)));
    } catch (e) {
      console.error("Fetch error:", e);
      setStatus("CONNECTION ERROR");
    }
  }, []);

  const createAccount = async (iban, balance) => {
    if (!iban) return setStatus("MISSING NAME!");
    setStatus("CREATING CHARACTER...");
    try {
      const response = await fetch(`${BASE_URL}/accounts`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ iban, amount: parseInt(balance) || 0 })
      });
      if (response.ok) {
        setStatus("NEW HERO JOINED!");
        await fetchAccounts();
        return true;
      }
    } catch (e) { setStatus("CREATION FAILED"); }
    return false;
  };

  const executeTransfer = async (from, to, amount) => {
    setStatus("CASTING SPELL...");
    try {
      const response = await fetch(`${BASE_URL}/transfer`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ from, to, amount: parseInt(amount) || 0 })
      });
      if (response.ok) {
        setStatus("TRANSFER SUCCESS!");
        await fetchAccounts();
        return true;
      } else {
        setStatus("FAILED!");
      }
    } catch (e) { setStatus("SPELL FIZZLED"); }
    return false;
  };

  useEffect(() => {
    fetchAccounts();
    const interval = setInterval(fetchAccounts, 500);
    return () => clearInterval(interval);
  }, [fetchAccounts]);

  return {
    accounts,
    status,
    actions: {
      createAccount,
      executeTransfer,
      refresh: fetchAccounts
    }
  };
}