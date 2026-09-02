require 'test_helper'
require 'base64'
require 'shrine/storage/memory'
require 'tempfile'

class ShrineUploaderTest < ActiveSupport::TestCase
  FILE_DATA = ->(id) {
    {
      'id' => id,
      'storage' => 'store',
      'metadata' => {
        'filename' => 'page.png',
        'size' => 1,
        'mime_type' => 'image/png'
      }
    }
  }

  test 'loads legacy versions as an original with derivatives' do
    attacher = ShrineUploader::Attacher.new
    attacher.load_data(
      'original' => FILE_DATA.call('picture/1/page.png'),
      'show_page' => FILE_DATA.call('picture/1/page_show_page.png'),
      'thumb' => FILE_DATA.call('picture/1/page_thumb.png')
    )

    assert_equal 'picture/1/page.png', attacher.file.id
    assert_equal 'picture/1/page_show_page.png', attacher.get(:show_page).id
    assert_equal 'picture/1/page_thumb.png', attacher.get(:thumb).id
  end

  test 'loads derivative data and preserves object naming' do
    attacher = ShrineUploader::Attacher.new
    attacher.load_data(
      FILE_DATA.call('picture/1/page.png').merge(
        'derivatives' => {
          'show_page' => FILE_DATA.call('picture/1/page_show_page.png'),
          'thumb' => FILE_DATA.call('picture/1/page_thumb.png')
        }
      )
    )

    assert_equal 'picture/1/page_show_page.png', attacher.get(:show_page).id
    assert_equal 'picture/1/page_thumb.png', attacher.get(:thumb).id

    record = ShrinePicture.new(id: 1)
    location = ShrineUploader.new(:store).generate_location(
      StringIO.new,
      record: record,
      metadata: { 'filename' => 'page.PNG' },
      derivative: :show_page
    )

    assert_equal 'picture/1/page_show_page.png', location
  end

  test 'promotes an original and creates derivatives in the new format' do
    previous_storages = ShrineUploader.storages
    ShrineUploader.storages = {
      cache: Shrine::Storage::Memory.new,
      store: Shrine::Storage::Memory.new
    }

    image = Tempfile.new(['page', '.png'])
    image.binmode
    image.write(Base64.decode64(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII='
    ))
    image.rewind
    image.define_singleton_method(:original_filename) { 'page.png' }

    picture = ShrinePicture.create!(picture: image)
    data = JSON.parse(picture.picture_data)

    assert_equal "picture/#{picture.id}/page.png", data['id']
    assert_equal "picture/#{picture.id}/page_show_page.png", data.dig('derivatives', 'show_page', 'id')
    assert_equal "picture/#{picture.id}/page_thumb.png", data.dig('derivatives', 'thumb', 'id')
    assert_equal picture.picture.url, picture.picture_url
    assert_equal picture.picture(:show_page).url, picture.picture_url(:show_page)
  ensure
    picture&.destroy!
    image&.close!
    ShrineUploader.storages = previous_storages
  end

  test 'detects MIME type from bytes and rejects deceptive image metadata' do
    file = Tempfile.new(['not-an-image', '.png'])
    file.binmode
    file.write("plain text presented as a PNG")
    file.rewind
    file.define_singleton_method(:original_filename) { 'not-an-image.png' }
    file.define_singleton_method(:content_type) { 'image/png' }

    picture = ShrinePicture.new(picture: file)

    assert_not picture.valid?
    assert_includes picture.errors[:picture], "type must be one of: image/gif, image/jpeg, image/png, image/webp"
    assert_not_equal "image/png", picture.picture.mime_type
  ensure
    file&.close!
  end
end
