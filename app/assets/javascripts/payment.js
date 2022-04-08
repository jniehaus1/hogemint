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

async function confirmWithServer(confirmationNumber, receipt, retryNum, nonce, signedMsg, saleID) {
    if (retryNum > numberRetries) return;

    if (confirmationNumber > 2 && !confirmationFlag) {
        showTx.innerHTML = "Transaction Completed!";
        confirmationFlag = true;
        $.ajax({
            type: "POST",
            url: $("#callback_url").html(),
            data: { receipt: receipt,
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
