const express = require('express');
const cors = require('cors');
const algosdk = require('algosdk');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Algorand Testnet Configuration
const ALGOD_TOKEN = '';
const ALGOD_SERVER = 'https://testnet-api.algonode.cloud';
const ALGOD_PORT = 443;

// Testnet Wallets
// Wallet 1: Primary spending wallet (sender)
const WALLET1_MNEMONIC = 'limb junk pond fame radio black already anxiety fold wide olive funny boat shallow piano rude width castle truth sand loop tonight track absent whale';
const WALLET1_ADDRESS = 'A4LCT5DIHALLMID6J3F5DLOIFWOU7PPEF6GPIA2FA37UYXCLORMT537TOI';

// Wallet 2: Recipient wallet (merchant)
const WALLET2_ADDRESS = 'QWCF2G23COMXXBZQVOJHLIH74YDACEZBQGD5RQTKPMTUXEGJONEBDKGLNA';

// Initialize Algod Client
const algodClient = new algosdk.Algodv2(ALGOD_TOKEN, ALGOD_SERVER, ALGOD_PORT);

// Helper function to get account from mnemonic
function getAccountFromMnemonic(mnemonic) {
    try {
        return algosdk.mnemonicToSecretKey(mnemonic);
    } catch (error) {
        throw new Error(`Invalid mnemonic: ${error.message}`);
    }
}

// POST /submit-transaction
app.post('/submit-transaction', async (req, res) => {
    try {
        const { amount, merchant, category } = req.body;

        // Validate request
        if (amount === undefined || !merchant || !category) {
            return res.status(400).json({
                success: false,
                error: 'Missing required fields: amount, merchant, category'
            });
        }

        console.log('📤 Received transaction request:');
        console.log(`   Amount: $${amount}`);
        console.log(`   Merchant: ${merchant}`);
        console.log(`   Category: ${category}`);

        // Get account from mnemonic
        const account = getAccountFromMnemonic(WALLET1_MNEMONIC);

        // Convert amount to microALGO
        // According to Swift code comment: "Sends amount/100 in ALGO from wallet 1 to wallet 2"
        // So if amount is $50.00, we send 0.5 ALGO = 500,000 microALGO
        const algoAmount = amount / 100;
        const microAlgoAmount = Math.floor(algoAmount * 1000000); // Convert to microALGO

        console.log(`   Converting: $${amount} → ${algoAmount} ALGO → ${microAlgoAmount} microALGO`);

        // Get suggested transaction parameters
        const suggestedParams = await algodClient.getTransactionParams().do();

        // Create payment transaction
        const transaction = algosdk.makePaymentTxnWithSuggestedParamsFromObject({
            from: account.addr,
            to: WALLET2_ADDRESS,
            amount: microAlgoAmount,
            suggestedParams: suggestedParams,
            note: new Uint8Array(
                Buffer.from(`ClearSpend: ${merchant} - ${category} - $${amount}`)
            )
        });

        // Sign transaction
        const signedTxn = transaction.signTxn(account.sk);
        const txId = transaction.txID().toString();

        console.log(`   Transaction ID: ${txId}`);

        // Submit transaction
        await algodClient.sendRawTransaction(signedTxn).do();

        // Wait for confirmation
        console.log('   Waiting for confirmation...');
        const confirmedTxn = await algosdk.waitForConfirmation(
            algodClient,
            txId,
            4
        );

        console.log(`✅ Transaction confirmed in round ${confirmedTxn['confirmed-round']}`);

        // Return success response
        res.json({
            success: true,
            transactionId: txId,
            amount: amount,
            merchant: merchant,
            category: category,
            algoAmount: algoAmount,
            explorerLink: `https://testnet.algoexplorer.io/tx/${txId}`
        });

    } catch (error) {
        console.error('❌ Transaction error:', error);
        res.status(500).json({
            success: false,
            error: error.message || 'Failed to submit transaction'
        });
    }
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'ok', service: 'transaction-service' });
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 Transaction Service running on http://localhost:${PORT}`);
    console.log(`📡 Algorand Testnet: ${ALGOD_SERVER}`);
    console.log(`💰 Wallet 1 (Sender): ${WALLET1_ADDRESS}`);
    console.log(`💰 Wallet 2 (Recipient): ${WALLET2_ADDRESS}`);
    console.log(`\n✅ Ready to process transactions!\n`);
});

