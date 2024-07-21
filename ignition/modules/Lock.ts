import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Lock", (m: any) => {
  const chatApp = m.contract("ChatApp");

  return chatApp;
});
