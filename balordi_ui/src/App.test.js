import { render, screen } from '@testing-library/react';
import App from './App';

test('renders Balordi Bank title', () => {
  render(<App />);
  const titleElement = screen.getByText(/BALORDI BANK/i);
  expect(titleElement).toBeInTheDocument();
});

test('renders status bar with initial player message', () => {
  render(<App />);
  const statusElement = screen.getByText(/READY PLAYER ONE/i);
  expect(statusElement).toBeInTheDocument();
});

test('renders the Press Start button', () => {
  render(<App />);
  const buttonElement = screen.getByText(/PRESS START/i);
  expect(buttonElement).toBeInTheDocument();
});

test('renders the New Character section', () => {
  render(<App />);
  const sectionTitle = screen.getByText(/NEW CHARACTER/i);
  expect(sectionTitle).toBeInTheDocument();
});