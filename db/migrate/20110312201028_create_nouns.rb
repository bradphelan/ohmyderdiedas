class CreateNouns < ActiveRecord::Migration
  def self.up
    create_table :nouns do |t|
      t.string :word
      t.string :gender
    end
    add_index :nouns, :word
    add_index :nouns, :gender
  end

  def self.down
    drop_table :nouns
  end
end
