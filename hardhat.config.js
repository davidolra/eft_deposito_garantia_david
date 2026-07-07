import { defineConfig } from "hardhat/config";
import hardhatEthers from "@nomicfoundation/hardhat-ethers";

export default defineConfig({
  plugins: [hardhatEthers],
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      // --- NOTA PEDAGÓGICA ---
      // El compilador de Solidity 0.8.20 introduce el opcode PUSH0 (EVM Shanghai).
      // Algunas redes locales o testnets más antiguas no lo soportan. Si se despliega en una red
      // incompatible, se puede cambiar el "evmVersion" a "paris" o "london".
      evmVersion: "shanghai"
    },
  },
  paths: {
    sources: "./src",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  }
});
