require "redcarpet"

module BitPlayer
  class Slide < ActiveRecord::Base
    belongs_to :slideshow,
      class_name: "BitPlayer::Slideshow",
      foreign_key: :bit_player_slideshow_id,
      inverse_of: :slides

    validates :title, :body, :position, presence: true
    validates_numericality_of :position, greater_than_or_equal_to: 1
    validates_uniqueness_of :position, scope: :bit_player_slideshow_id

    def render_body
      rendered = ""

      if !body.nil?
        markdown = Redcarpet::Markdown.new(
          Redcarpet::Render::HTML.new(
            filter_html: true,
            safe_links_only: true
          ),
          space_after_headers: true,
        )
        rendered += markdown.render(body)
      end

      rendered.html_safe
    end

    def self.update_positions(ids)
      transaction do
        connection.execute "SET CONSTRAINTS slide_position DEFERRED"
        ids.each_with_index do |id, index|
          where(id: id).update_all(position: index + 1)
        end
      end
    end
  end
end
