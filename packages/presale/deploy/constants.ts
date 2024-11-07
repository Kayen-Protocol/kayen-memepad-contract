interface NetworkAddresses {
  wETH: string;
  FEE_VAULT_ADDRESS: string;
  V2_FACTORY: string;
  V2_ROUTER: string;
}

const NETWORK_ADDRESSES: { [key: number]: NetworkAddresses } = {
  // Sepolia
  11155111: {
    wETH: "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14",
    FEE_VAULT_ADDRESS: "0x86d36bd2EEfB7974B9D0720Af3418FC7Ca5C8897",
    V2_FACTORY: "",
    V2_ROUTER: "",
  },
  // Chiliz Spicy Testnet
  88882: {
    wETH: "0x678c34581db0a7808d0aC669d7025f1408C9a3C6",
    FEE_VAULT_ADDRESS: "0x86d36bd2EEfB7974B9D0720Af3418FC7Ca5C8897", //
    V2_FACTORY: "0xfc1924E20d64AD4daA3A4947b4bAE6cDE77d2dBC",
    V2_ROUTER: "0xb82b0e988a1FcA39602c5079382D360C870b44c8",
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
