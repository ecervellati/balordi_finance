import React, { useState } from 'react';
import './App.css';
import { useBankLogic } from './hooks/bankLogic';

function App() {
  const { accounts, status, actions } = useBankLogic();
  const [formAccount, setFormAccount] = useState({ iban: "", balance: null });
  const [formTransfer, setFormTransfer] = useState({ from: "", to: "", amount: null });

  const handleCreate = async () => {
    const success = await actions.createAccount(formAccount.iban, formAccount.balance);
    if (success) setFormAccount({ iban: "", balance: 0 });
  };

  const handleTransfer = async () => {
    const success = await actions.executeTransfer(formTransfer.from, formTransfer.to, formTransfer.amount);
    if (success) setFormTransfer({ ...formTransfer, amount: 0 });
  };

  return (
    <div className="retro-container">
      <h1 className="retro-title">BALORDI BANK</h1>
      <div className="status-bar">{status}</div>

      {/* --- Creation control --- */}
      <div className="pixel-panel">
        <h3>NEW CHARACTER</h3>
        <div className="input-group">
          <input type="text" placeholder="IBAN" value={formAccount.iban} 
                 onChange={e => setFormAccount({...formAccount, iban: e.target.value})} />
          <input type="number" placeholder="GOLD" value={formAccount.balance} 
                 onChange={e => setFormAccount({...formAccount, balance: e.target.value})} />
          <button className="pixel-button small" onClick={handleCreate}>ADD</button>
        </div>
      </div>

      {/* --- Table control --- */}
      <table className="pixel-table">
        <thead><tr><th>PLAYER</th><th style={{textAlign:'right'}}>GOLD</th></tr></thead>
        <tbody>
          {accounts.map(acc => (
            <tr key={acc.iban} className="pixel-row">
              <td className="pixel-iban"><span className="challenger-label">CHALLENGER:</span> {acc.iban}</td>
              <td className={acc.amount >= 0 ? 'score-positive' : 'score-negative'} style={{textAlign:'right'}}>{acc.amount}G</td>
            </tr>
          ))}
        </tbody>
      </table>

      {/* --- Transfer control --- */}
      <div className="pixel-panel" style={{marginTop: '20px'}}>
        <h3>QUICK SPELL</h3>
        <div className="input-group vertical">
          <input type="text" placeholder="FROM" value={formTransfer.from} 
                 onChange={e => setFormTransfer({...formTransfer, from: e.target.value})} />
          <input type="text" placeholder="TO" value={formTransfer.to} 
                 onChange={e => setFormTransfer({...formTransfer, to: e.target.value})} />
          <input type="number" placeholder="AMOUNT" value={formTransfer.amount} 
                 onChange={e => setFormTransfer({...formTransfer, amount: e.target.value})} />
          <button className="pixel-button" onClick={handleTransfer}>PRESS START</button>
        </div>
      </div>
    </div>
  );
}

export default App;