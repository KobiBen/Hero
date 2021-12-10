import Vue from "vue";
import Vuex from "vuex";
import { ethers } from "ethers";
import Hero from "../utils/Hero.json";

Vue.use(Vuex);

// const transformCharacterData = (characterData) => {
//   return {
//     name: characterData.name,
//     imageURI: characterData.imageURI,
//     hp: characterData.hp.toNumber(),
//     maxHp: characterData.maxHp.toNumber(),
//     attackDamage: characterData.attackDamage.toNumber(),
//   };
// };

export default new Vuex.Store({
  state: {
    account: null,
    error: null,
    contract_address: "0x0B3E4A623d1c68AE0Ac996782b55Dabbf9A02A70",

  },
  getters: {
    account: (state) => state.account,
    error: (state) => state.error,
    // mining: (state) => state.mining,
    // characterNFT: (state) => state.characterNFT,
    // characters: (state) => state.characters,
  },
  mutations: {
    setAccount(state, account) {
      state.account = account;
    },
    setError(state, error) {
      state.error = error;
    },
    // setMining(state, mining) {
    //   state.mining = mining;
    // },
    // setCharacterNFT(state, characterNFT) {
    //   state.characterNFT = characterNFT;
    // },
    // setCharacters(state, characters) {
    //   state.characters = characters;
    // },
  },
  actions: {
    async connect({ commit, dispatch }, connect) {
      try {
        const { ethereum } = window;
        if (!ethereum) {
          commit("setError", "Metamask not installed!");
          return;
        }
        if (!(await dispatch("checkIfConnected")) && connect) {
          await dispatch("requestAccess");
        }
        await dispatch("checkNetwork");
        await dispatch("Upgraded");
        // await dispatch("setupEventListeners");
      } catch (error) {
        console.log(error);
        commit("setError", "Account request refused.");
      }
    },
    async checkNetwork({ commit, dispatch }) {
      const { ethereum } = window;
      let chainId = await ethereum.request({ method: "eth_chainId" });
      //const ropstenChainId = "0x3";
      const rinkebyChainId = "0x4";
      if (chainId !== rinkebyChainId) {
        if (!(await dispatch("switchNetwork"))) {
          commit(
            "setError",
            "You are not connected to the Rinkeby Test Network!"
          );
        }
      }
    },
    async switchNetwork() {
      try {
        const { ethereum } = window;
        await ethereum.request({
          method: "wallet_switchEthereumChain",
          params: [{ chainId: "0x4" }],
        });
        return 1;
      } catch (switchError) {
        return 0;
      }
    },
    async checkIfConnected({ commit }) {
      const { ethereum } = window;
      const accounts = await ethereum.request({ method: "eth_accounts" });
      if (accounts.length !== 0) {
        commit("setAccount", accounts[0]);
        return 1;
      } else {
        return 0;
      }
    },
    async requestAccess({ commit }) {
      const { ethereum } = window;
      const accounts = await ethereum.request({
        method: "eth_requestAccounts",
      });
      commit("setAccount", accounts[0]);
    },
    async getContract({ state }) {
      try {
        const { ethereum } = window;
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const connectedContract = new ethers.Contract(
          state.contract_address,
          Hero.abi,
          signer
        );
        return connectedContract;
      } catch (error) {
        console.log(error);
        console.log("connected contract not found");
        return null;
      }
    },
    async createNft({ dispatch }){
      try {
        const connectedContract = await dispatch("getContract");
        let name = "test name1";
        const txn = await connectedContract.createRandomHero(name, { value: ethers.utils.parseEther("0.03") });
        console.log(txn);

      } catch (error) {
        console.log(error);
      }
    },
    async Upgraded({  dispatch }) {
      try {
        const connectedContract = await dispatch("getContract");
        const txn = await connectedContract.renderHelloWorld();
        console.log("txn:" + txn);

      } catch (error) {
        console.log(error);
      }
    },
  },
});