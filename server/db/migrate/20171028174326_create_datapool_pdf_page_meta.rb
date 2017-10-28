class CreateDatapoolPdfPageMeta < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_pdf_page_meta do |t|
      t.integer :datapool_pdf_metum_id, null: false
      t.integer :page_number, null: false, default: 0
      t.string :extract_image_url
      t.text :text
      t.text :options
    end
    add_index :datapool_pdf_page_meta, [:datapool_pdf_metum_id, :page_number], name: "pdf_metum_id__and_page_index"
  end
end
