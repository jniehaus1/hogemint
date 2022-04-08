require "rails_helper"

RSpec.describe MintWorker do
  describe "#perform" do
    let(:generation)  { "three" }
    let(:private_key) { "8da4ef21b864d2cc526dbdb2a120bd2874c36c9d0a1fb7f8c63d7f7a8b41de8f" }

    before do
      ENV["GEN_#{generation.upcase}_MINT_ADDRESS"] = generation
      ENV["GEN_#{generation.upcase}_MINT_PRIVATE_KEY"] = private_key
      ENV["CURRENT_GENERATION"] = "three"
      allow_any_instance_of(Generations::Three).to receive(:run_validations).and_return(true)
      allow_any_instance_of(Generations::Three).to receive(:generate_card).and_return(nil)
      allow_any_instance_of(Generations::Three).to receive(:run_after_create).and_return(true)
    end

    subject { MintWorker.perform_async(sale.id, generation) }

    context "gen three good params" do
      let(:sale) { create(:sale, nft_asset: item, aasm_state: "paid") }
      let(:item) { create(:item) }

      it "calls NftPrinter::Create" do
        expect(NftPrinter::Create).to receive(:call).with(sale, generation, private_key).and_return(nil)
        subject
        MintWorker.drain
        expect(sale.reload.aasm_state).to eq("pending_tx")
      end
    end

    context "fails somewhere in NftPrinter::Create" do
      let(:sale) { create(:sale, nft_asset: item, aasm_state: "paid") }
      let(:item) { create(:item) }

      it "changes sale state to failed, does NOT reraise and keep trying" do
        expect(NftPrinter::Create).to receive(:call).with(sale, generation, private_key).and_raise("Something went wrong")
        subject
        expect { MintWorker.drain }.not_to raise_error
        expect(sale.reload.aasm_state).to eq("failed_to_mint")
      end
    end
  end
end
