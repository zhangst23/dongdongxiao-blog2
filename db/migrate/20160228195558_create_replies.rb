class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies do |t|
	  t.integer  :user_id                       
	  t.integer  :topic_id                     
	  t.text     :body                       
	  t.text     :body_html
	  t.integer  :state          
	  t.integer  :liked_user_ids                
	  t.integer  :likes_count     
	  t.integer  :mentioned_user_ids              
	  t.datetime :deleted_at





      t.timestamps null: false
    end
  end
end
