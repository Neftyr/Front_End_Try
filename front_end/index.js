import { ethers } from "./ethers-5.6.esm.min.js"
import { abi, contractAddress } from "./constants.js"

const connectButton = document.getElementById("connectButton")
connectButton.onclick = connect
const pryntButton = document.getElementById("pryntButton")
pryntButton.onclick = checkCerts
const addButton = document.getElementById("addButton")
addButton.onclick = addCert

async function connect() {
    if (typeof window.ethereum !== "undefined") {
      try {
        await ethereum.request({ method: "eth_requestAccounts" })
      } catch (error) {
        console.log(error)
      }
      connectButton.innerHTML = "Connected"
      const accounts = await ethereum.request({ method: "eth_accounts" })
      console.log(accounts)
    } else {
      connectButton.innerHTML = "Please install MetaMask"
    }
}

async function prynt() {
    pryntButton.innerHTML = "prynt"
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()
    const signer_address = signer.getAddress(this)
    const contract = new ethers.Contract(contractAddress, abi, signer)
    const fee = contract.getMinimumFee()
    const f = fee.toString()
    console.log(fee)
}

async function addCert(){
  
  //const contract.address
  const d = new Date();
  let date = d.toString();
  const ethAmount = "0.05"
  
  console.log(`Adding Certificate...`)
  if (typeof window.ethereum !== "undefined") {
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()
    const signer_address = signer.getAddress(this)
    const contract = new ethers.Contract(contractAddress, abi, signer)
    const nonce = await provider.getTransactionCount(contractAddress)
    const anticipatedAddress = ethers.utils.getContractAddress({from: contractAddress, nonce})
    try {
      const transactionResponse = await contract.addCertificate(anticipatedAddress, date, "second", signer_address, "third", "fourth", "hashx0", {
          value: ethers.utils.parseEther(ethAmount)},)
      await listenForTransactionMine(transactionResponse, provider)
    } catch (error) {
      console.log(error)
    }
  } else {
    addButton.innerHTML = "Please install MetaMask"
  }
}

async function checkCerts(){
  console.log(`Checking Certificates...`)
  if (typeof window.ethereum !== "undefined") {
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()
    const signer_address = signer.getAddress(this)
    const contract = new ethers.Contract(contractAddress, abi, signer)
    try {
      const out = contract.getCertificatesYouOwn(signer_address)
      console.log(out)
    } catch (error) {
      console.log(error)
    }
  } else {
    addButton.innerHTML = "Please install MetaMask"
  }
}

async function transferOwnership(){
  
  input1 = x
  input2 = y

  //const ethAmount = "0.05"
  
  console.log(`Transferring Ownership...`)
  if (typeof window.ethereum !== "undefined") {
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()
    const signer_address = signer.getAddress(this)
    const contract = new ethers.Contract(contractAddress, abi, signer)
    const fee = contract.getMinimumFee()
    try {
      const transactionResponse = await contract.transferOwnership(signer_address, input1, input2, {
          value: ethers.utils.parseEther(fee)},)
      await listenForTransactionMine(transactionResponse, provider)
    } catch (error) {
      console.log(error)
    }
  } else {
    addButton.innerHTML = "Please install MetaMask"
  }
}
