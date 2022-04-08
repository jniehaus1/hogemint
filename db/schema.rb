# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_03_18_202306) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "base_items", force: :cascade do |t|
    t.string "uri"
    t.string "owner"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.bigint "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "coin_gate_receipts", force: :cascade do |t|
    t.string "invoice_id"
    t.string "status"
    t.string "price_currency"
    t.string "price_amount"
    t.string "receive_currency"
    t.string "receive_amount"
    t.string "pay_amount"
    t.string "pay_currency"
    t.string "underpaid_amount"
    t.string "overpaid_amount"
    t.string "is_refundable"
    t.string "remote_created_at"
    t.string "order_id"
    t.integer "sale_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", force: :cascade do |t|
    t.integer "token_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uri"
    t.string "owner"
    t.string "image_hash"
    t.string "flavor_text"
    t.string "title"
    t.string "image_file_name"
    t.string "image_content_type"
    t.bigint "image_file_size"
    t.datetime "image_updated_at"
    t.string "meme_card_file_name"
    t.string "meme_card_content_type"
    t.bigint "meme_card_file_size"
    t.datetime "meme_card_updated_at"
    t.integer "generation"
    t.boolean "is_flagged"
    t.boolean "processing", default: true
    t.string "ipfs_image_file_cid"
    t.string "ipfs_image_json_cid"
    t.string "ipfs_meme_file_cid"
    t.string "ipfs_meme_json_cid"
    t.string "generated_gif_url"
  end

  create_table "now_payments", force: :cascade do |t|
    t.string "payment_id"
    t.string "payment_status"
    t.string "price_amount"
    t.string "price_currency"
    t.string "pay_amount"
    t.string "pay_currency"
    t.string "order_id"
    t.string "order_description"
    t.string "ipn_callback_url"
    t.string "purchase_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "np_receipts", force: :cascade do |t|
    t.string "payment_id"
    t.string "payment_status"
    t.string "pay_address"
    t.string "price_amount"
    t.string "price_currency"
    t.string "pay_amount"
    t.string "actually_paid"
    t.string "pay_currency"
    t.string "order_id"
    t.string "order_description"
    t.string "purchase_id"
    t.string "outcome_amount"
    t.string "outcome_currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sale_id"
  end

  create_table "polygon_receipts", force: :cascade do |t|
    t.string "amount"
    t.integer "item_id"
    t.string "msg"
    t.string "nonce"
    t.integer "sale_id"
    t.string "signed_msg"
    t.string "tx_hash"
    t.string "wallet"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sales", force: :cascade do |t|
    t.integer "quantity"
    t.integer "gas_for_mint"
    t.string "nft_owner"
    t.integer "nft_asset_id"
    t.float "gas_price"
    t.integer "coingate_receipt"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "aasm_state"
    t.string "nft_asset_type"
    t.string "merchant_order_id"
    t.string "coingate_order_id"
    t.string "payment_id"
    t.string "invoice_url"
    t.string "tx_hash"
    t.string "mint_price"
    t.string "nonce"
  end

  create_table "test_items", force: :cascade do |t|
    t.integer "token_id"
    t.string "uri"
    t.string "owner"
    t.string "image_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "flavor_text"
    t.string "title"
    t.string "image_file_name"
    t.string "image_content_type"
    t.bigint "image_file_size"
    t.datetime "image_updated_at"
    t.string "meme_card_file_name"
    t.string "meme_card_content_type"
    t.bigint "meme_card_file_size"
    t.datetime "meme_card_updated_at"
    t.integer "generation"
  end

  create_table "tokens", force: :cascade do |t|
    t.string "uri"
    t.string "owner"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
