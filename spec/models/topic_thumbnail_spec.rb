# frozen_string_literal: true
require 'rails_helper'

describe "TopicThumbnail" do
  let(:upload1) { Fabricate(:image_upload, width: 5000, height: 5000) }
  let(:topic) { Fabricate(:topic, image_upload: upload1) }
  let(:upload2) { Fabricate(:image_upload, width: 5000, height: 5000) }
  let(:topic2) { Fabricate(:topic, image_upload: upload2) }

  before do
    SiteSetting.create_thumbnails = true
    topic.generate_thumbnails!(extra_sizes: nil)

    TopicThumbnail.ensure_consistency!
    topic.reload

    expect(topic.topic_thumbnails.length).to eq(1)
  end

  it "does not enque job if original image is too large" do
    upload2.filesize = SiteSetting.max_image_size_kb.kilobytes + 1
    SiteSetting.create_thumbnails = true
    topic2.generate_thumbnails!(extra_sizes: nil)

    TopicThumbnail.ensure_consistency!
    topic2.reload

    expect(topic2.topic_thumbnails.length).to eq(0)
  end

  it "cleans up deleted uploads" do
    upload1.delete

    TopicThumbnail.ensure_consistency!
    topic.reload

    expect(topic.topic_thumbnails.length).to eq(0)
  end

  it "cleans up deleted optimized images" do
    upload1.optimized_images.reload.delete_all

    TopicThumbnail.ensure_consistency!
    topic.reload

    expect(topic.topic_thumbnails.length).to eq(0)
  end

  it "cleans up unneeded sizes" do
    expect(topic.topic_thumbnails.length).to eq(1)
    topic.topic_thumbnails[0].update_column(:max_width, 999999)

    TopicThumbnail.ensure_consistency!
    topic.reload

    expect(topic.topic_thumbnails.length).to eq(0)
  end

end
