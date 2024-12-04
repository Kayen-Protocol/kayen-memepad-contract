interface NetworkAddresses {
  wETH: string;
  FEE_VAULT_ADDRESS: string;
  V2_FACTORY: string;
  V2_ROUTER: string;
  owner: string;
}

const NETWORK_ADDRESSES: { [key: number]: NetworkAddresses } = {
  // Sepolia
  11155111: {
    wETH: "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14",
    FEE_VAULT_ADDRESS: "0x86d36bd2EEfB7974B9D0720Af3418FC7Ca5C8897",
    V2_FACTORY: "0xfc1924E20d64AD4daA3A4947b4bAE6cDE77d2dBC",
    V2_ROUTER: "0xb82b0e988a1FcA39602c5079382D360C870b44c8",
    owner: "",
  },
  // Chiliz Spicy Testnet
  88882: {
    wETH: "0x678c34581db0a7808d0aC669d7025f1408C9a3C6",
    FEE_VAULT_ADDRESS: "0x86d36bd2EEfB7974B9D0720Af3418FC7Ca5C8897", //
    V2_FACTORY: "0xfc1924E20d64AD4daA3A4947b4bAE6cDE77d2dBC",
    V2_ROUTER: "0xb82b0e988a1FcA39602c5079382D360C870b44c8",
    owner: "",
  },
  // Chiliz Mainnet
  88888: {
    wETH: "0x677F7e16C7Dd57be1D4C8aD1244883214953DC47",
    FEE_VAULT_ADDRESS: "0x80B714e2dd42611e4DeA6BFe2633210bD9191bEd", //
    V2_FACTORY: "0xE2918AA38088878546c1A18F2F9b1BC83297fdD3",
    V2_ROUTER: "0x1918EbB39492C8b98865c5E53219c3f1AE79e76F",
    owner: "0x80B714e2dd42611e4DeA6BFe2633210bD9191bEd",
  },
  //
  1513: {
    wETH: "0x6e990040Fd9b06F98eFb62A147201696941680b5",
    FEE_VAULT_ADDRESS: "0x86d36bd2EEfB7974B9D0720Af3418FC7Ca5C8897", //
    V2_FACTORY: "0x02F75bdBb4732cc6419aC15EeBeE6BCee66e826f",
    V2_ROUTER: "0x56300f2dB653393e78C7b5edE9c8f74237B76F47",
    owner: "",
  },
  // add network here if needed.
};

export const getNetworkAddresses = (networkId: number): NetworkAddresses => {
  const addresses = NETWORK_ADDRESSES[networkId];
  if (!addresses) {
    throw new Error(`Addresses not configured for network: ${networkId}`);
  }
  return addresses;
};
