import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import '@openzeppelin/hardhat-upgrades';


const config: HardhatUserConfig = {
  solidity: "0.8.18",

  networks: {
    localhost: {
        url: "http://localhost:8545",
        chainId: 31337
    }
  }
};

export default config;
