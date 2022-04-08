const Web3Modal = window.Web3Modal.default;
const WalletConnectProvider = window.WalletConnectProvider.default;
const evmChains = window.evmChains;

// Web3modal instance
let web3Modal;
// Chosen wallet provider given by the dialog window
let provider;
// Address of the selected account
let selectedAccount;

let numberRetries = 5;
let confirmationFlag = false;
let guid;

function init() {
    console.log("Initializing example");
    console.log("WalletConnectProvider is", WalletConnectProvider);
    console.log("window.web3 is", window.web3, "window.ethereum is", window.ethereum);

    // Check that the web page is run in a secure context,
    // as otherwise MetaMask won't be available
    // if(location.protocol !== 'https:') {
    //     // https://ethereum.stackexchange.com/a/62217/620
    //     const alert = document.querySelector("#alert-error-https");
    //     // alert.style.display = "block";
    //     document.querySelector("#btn-connect").setAttribute("disabled", "disabled")
    //     return;
    // }

    // Tell Web3modal what providers we have available.
    // Built-in web browser provider (only one can exist as a time)
    // like MetaMask, Brave or Opera is added automatically by Web3modal
    const providerOptions = {
        walletconnect: {
            package: WalletConnectProvider,
            options: {
                // Mikko's test key - don't copy as your mileage may vary
                infuraId: "8043bb2cf99347b1bfadfb233c5325c0",
            }
        },

        // fortmatic: {
        //     package: Fortmatic,
        //     options: {
        //         // Mikko's TESTNET api key
        //         key: "pk_test_391E26A3B43A3350"
        //     }
        // }
    };

    web3Modal = new Web3Modal({
        cacheProvider: false, // optional
        providerOptions, // required
        disableInjectedProvider: false, // optional. For MetaMask / Brave / Opera.
    });

    console.log("Web3Modal instance is", web3Modal);
}


/**
 * Kick in the UI action after Web3modal dialog has chosen a provider
 */
async function fetchAccountData() {

    // Get a Web3 instance for the wallet
    const web3 = new Web3(provider);

    console.log("Web3 instance is", web3);

    // Get connected chain id from Ethereum node
    const chainId = await web3.eth.getChainId();
    // Load chain information over an HTTP API
    const chainData = evmChains.getChain(chainId);
    document.querySelector("#network-name").textContent = chainData.name;

    // Get list of accounts of the connected wallet
    const accounts = await web3.eth.getAccounts();

    // MetaMask does not give you all accounts, only the selected account
    console.log("Got accounts", accounts);
    selectedAccount = accounts[0];

    document.querySelector("#selected-account").textContent = selectedAccount;

    // Get a handl
    const template = document.querySelector("#template-balance");
    const accountContainer = document.querySelector("#accounts");

    // Purge UI elements any previously loaded accounts
    accountContainer.innerHTML = '';

    // Go through all accounts and get their ETH balance
    const rowResolvers = accounts.map(async (address) => {
        const balance = await web3.eth.getBalance(address);
        // ethBalance is a BigNumber instance
        // https://github.com/indutny/bn.js/
        const ethBalance = web3.utils.fromWei(balance, "ether");
        const humanFriendlyBalance = parseFloat(ethBalance).toFixed(4);
        // Fill in the templated row and put in the document
        const clone = template.content.cloneNode(true);
        clone.querySelector(".address").textContent = address;
        clone.querySelector(".balance").textContent = humanFriendlyBalance;
        accountContainer.appendChild(clone);
    });

    // Because rendering account does its own RPC commucation
    // with Ethereum node, we do not want to display any results
    // until data for all accounts is loaded
    await Promise.all(rowResolvers);

    // Display fully loaded UI for wallet data
    document.querySelector("#prepare").style.display = "none";
    document.querySelector("#connected").style.display = "block";
}



/**
 * Fetch account data for UI when
 * - User switches accounts in wallet
 * - User switches networks in wallet
 * - User connects wallet initially
 */
async function refreshAccountData() {

    // If any current data is displayed when
    // the user is switching acounts in the wallet
    // immediate hide this data
    document.querySelector("#connected").style.display = "none";
    document.querySelector("#prepare").style.display = "block";

    // Disable button while UI is loading.
    // fetchAccountData() will take a while as it communicates
    // with Ethereum node via JSON-RPC and loads chain data
    // over an API call.
    document.querySelector("#btn-connect").setAttribute("disabled", "disabled")
    await fetchAccountData(provider);
    document.querySelector("#btn-connect").removeAttribute("disabled")
}


/**
 * Connect wallet button pressed.
 */
async function onConnect() {

    console.log("Opening a dialog", web3Modal);
    try {
        provider = await web3Modal.connect();
    } catch(e) {
        console.log("Could not get a wallet connection", e);
        return;
    }

    // // Subscribe to accounts change
    // provider.on("accountsChanged", (accounts) => {
    //     fetchAccountData();
    // });
    //
    // // Subscribe to chainId change
    // provider.on("chainChanged", (chainId) => {
    //     fetchAccountData();
    // });
    //
    // // Subscribe to networkId change
    // provider.on("networkChanged", (networkId) => {
    //     fetchAccountData();
    // });

    // await refreshAccountData();
}

/**
 * Disconnect wallet button pressed.
 */
async function onDisconnect() {

    console.log("Killing the wallet connection", provider);

    // TODO: Which providers have close method?
    if(provider.close) {
        await provider.close();

        // If the cached provider is not cleared,
        // WalletConnect will default to the existing session
        // and does not allow to re-scan the QR code with a new wallet.
        // Depending on your use case you may want or want not his behavir.
        await web3Modal.clearCachedProvider();
        provider = null;
    }

    selectedAccount = null;

    // Set the UI back to the initial state
    document.querySelector("#prepare").style.display = "block";
    document.querySelector("#connected").style.display = "none";
}

async function signMessage() {
    if (provider === undefined) { await onConnect(); }

    const web3 = new Web3(provider);

    var nonce = $("#nonce").val();
    var msg = "We generated a token to prove that you're you! Sign with your account to protect your data. Unique Token: " + nonce;
    await web3.eth.getAccounts( function(error, accounts) {
        web3.eth.personal.sign(msg, accounts[0]).then(value => {
            addToForm(value);
            $("#submit-btn").removeAttr('disabled');
            $("#text-warning").addClass('d-none');
        });
    });
}

async function signTx(custodial_wallet, matic_fees, sale_id) {
    if (provider === undefined) { await onConnect(); }

    const web3 = new Web3(provider);

    var nonce = $("#nonce").val();
    var msg = "This signature helps our server verify the transaction and attribute your nft. Unique Token: " + nonce;
    await web3.eth.getAccounts( function(error, accounts) {
        web3.eth.personal.sign(msg, accounts[0]).then(value => {
            $("#signed_msg").val(value);
            generateNft(custodial_wallet, matic_fees, value, sale_id);
        });
    });
}

async function addToForm(signedMsg) {
    $("#item_signed_msg").val(signedMsg);
    $("#test_item_signed_msg").val(signedMsg);
}

async function confirmWithServer(confirmationNumber, receipt, retryNum, nonce, signedMsg, saleID) {
    if (retryNum > numberRetries) return;

    if (confirmationNumber > 0 && !confirmationFlag) {
        showTx.innerHTML = "Transaction Completed!";
        confirmationFlag = true;
        $.ajax({
            type: "POST",
            url: $("#callback_url").html(),
            data: { receipt: receipt,
                    node: ethereum.networkVersion,
                    nonce: nonce,
                    sale_id: saleID,
                    signed_msg: signedMsg },
            beforeSend: function (xhr) {
                xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
            },
            success: (data) => {
              if (data["retry"]) {
                console.log("Unable to confirm transfer from server, retrying...");
                sleep(1000);
                confirmWithServer(confirmationNumber, receipt, retryNum + 1);
              } else {
              // Do success stuff
              }
            },
        error: (data) => {
            console.log("Error communicating with server.");
            console.log(data)
          }
        })
    }
}


async function generateNft(custodial_wallet, matic_fees, signed_msg, sale_id) {
    if (provider === undefined) {
        await onConnect();
    }

    web3 = new Web3(provider);

    let showTx = $("#showTx");
    let nonce = $("#nonce").val();

    web3.eth.getAccounts( function (err, accounts) {
        $("#loading_spinner").removeClass("d-none");
        web3.eth.sendTransaction({from: accounts[0],
            to: custodial_wallet,
            gas: "21000",
            value: web3.utils.toWei(String(matic_fees), 'ether')})
            .on('transactionHash', function(hash){
                showTx.html("TX: " + hash);
            })
            .on('receipt', function(receipt){
                showTx.html("Confirming receipt.");
            })
            .on('confirmation', function(confirmationNumber, receipt){
                confirmWithServer(confirmationNumber, receipt, 0, nonce, signed_msg, sale_id);
                $("#loading_spinner").addClass("d-none");
            })
            .on('error', function(error) {
                console.error(error);
                showTx.html("User Canceled.");
                $("#loading_spinner").addClass("d-none");
            });
    })
}

/**
 * Main entry point.
 */
document.addEventListener("DOMContentLoaded", function(event) {
    init();
});
