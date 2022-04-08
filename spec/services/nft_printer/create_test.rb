require "rails_helper"

RSpec.describe NftPrinter::Create do
  describe "#call" do
    let(:item)         { create(:item) }
    let(:sale)         { create(:sale, nft_asset: item, gas_price: 1) }
    let(:mint_addr)    { "0x000000000000000000000000000000000000dead" }
    let(:private_key)  { "8da4ef21b864d2cc526dbdb2a120bd2874c36c9d0a1fb7f8c63d7f7a8b41de8f" } # Dead key
    let(:contract_dbl) { double("MintContract") }
    let(:transact_dbl) { double("TransactDbl") }
    let(:tx_id)        { double("tx", id: "some_tx_id") }

    let(:contract_args) { { name: "HogeNFTv3", address: mint_addr, abi: anything, client: anything } }

    subject { NftPrinter::Create.call(sale, mint_addr, private_key) }

    before do
      ENV["CURRENT_GENERATION"] = "three"
      allow_any_instance_of(Generations::Three).to receive(:run_validations).and_return(true)
      allow_any_instance_of(Generations::Three).to receive(:generate_card).and_return(nil)
      allow_any_instance_of(Generations::Three).to receive(:run_after_create).and_return(true)
    end

    context "has proper params" do
      it "makes appropriate calls" do
        expect(Etherscan::GasStation).to receive(:gas_price).and_return(1)
        expect(Ethereum::Contract).to receive(:create).with(contract_args).and_return(contract_dbl)
        expect(contract_dbl).to receive(:key=).and_return(true)
        expect(contract_dbl).to receive(:transact).and_return(transact_dbl)
        expect(transact_dbl).to receive(:mint).with(item.owner, item.uri).and_return(tx_id)
        subject
        expect(Sale.first.tx_hash).to eq(tx_id.id)
      end
    end

    context "gas is over 150" do
      it "raises error" do
        expect(Etherscan::GasStation).to receive(:gas_price).and_return(151)
        expect{ subject }.to raise_error("Gas too high")
      end
    end

    context "gas is over 15% of sale.gas_price" do
      it "raises error" do
        expect(Etherscan::GasStation).to receive(:gas_price).and_return(10)
        expect{ subject }.to raise_error("Gas much higher than invoice")
      end
    end
  end
end
