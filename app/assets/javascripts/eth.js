// window.ethereum.enable();
// web3 = new Web3(window.ethereum);
// web3.eth.getAccounts(function(error, accounts) { web3.eth.personal.sign("msg", accounts[0]).then(console.log)})
// web3.eth.personal.ecRecover("msg", "encoded_msg").then(console.log)

function doWeb3Thing() {
    console.log("Foo");
    a = App.init()
}

App = {
    web3Provider: null,
    contracts: {},

    init: async function() {
        return await App.initWeb3();
    },

    initWeb3: async function() {
        console.log('initweb3');
        // Modern dapp browsers...
        if (window.ethereum) {
            App.web3Provider = window.ethereum;
            try {
                // Request account access
                await window.ethereum.enable();
            } catch (error) {
                // User denied account access...
                console.error("User denied account access")
            }
        }
        // Legacy dapp browsers...
        else if (window.web3) {
            App.web3Provider = window.web3.currentProvider;
        }
        // If no injected web3 instance is detected, fall back to Ganache
        else {
            App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
        }
        web3 = new Web3(App.web3Provider);
        return App.signMessage();
    },

    signMessage: function() {
        var nonce = $('meta[name=nonce]').attr('content');
        var msg = "We generated a token to prove that you're you! Sign with your account to protect your data. Unique Token: " + nonce;
        web3.eth.getAccounts( function(error, accounts) {
            web3.eth.personal.sign(msg, accounts[0]).then(value => {
                App.addToForm(value);
                $("#submit-btn").removeAttr('disabled');
                $("#text-warning").addClass('d-none');
            });

        })
    },

    addToForm: function(signedMsg) {
        $("#item_signed_msg").val(signedMsg);
    }
};

$(window).on("load", function() {
    $("#sign_message-btn").on('click', doWeb3Thing);
});
