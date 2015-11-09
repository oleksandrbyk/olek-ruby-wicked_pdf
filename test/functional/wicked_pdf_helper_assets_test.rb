require 'test_helper'
require 'action_view/test_case'

class WickedPdfHelperAssetsTest < ActionView::TestCase
  include WickedPdfHelper::Assets

  if Rails::VERSION::MAJOR > 3 || (Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR > 0)
    test 'wicked_pdf_asset_base64 returns a base64 encoded asset' do
      source = File.new('test/fixtures/wicked.css', 'r')
      destination = Rails.root.join('app', 'assets', 'stylesheets', 'wicked.css')
      File.open(destination, 'w') { |f| f.write(source) }
      assert_match /data:text\/css;base64,.+/, wicked_pdf_asset_base64('wicked.css')
    end

    test 'wicked_pdf_asset_path should return a url when assets are served by an asset server' do
      expects(:asset_pathname => 'http://assets.domain.com/dummy.png')
      assert_equal 'http://assets.domain.com/dummy.png', wicked_pdf_asset_path('dummy.png')
    end

    test 'wicked_pdf_asset_path should return a url when assets are served by an asset server using HTTPS' do
      expects(:asset_path => 'https://assets.domain.com/dummy.png', 'precompiled_asset?' => true)
      assert_equal 'https://assets.domain.com/dummy.png', wicked_pdf_asset_path('dummy.png')
    end

    test 'wicked_pdf_asset_path should return a url with a protocol when assets are served by an asset server with relative urls' do
      expects(:asset_path => '//assets.domain.com/dummy.png')
      expects('precompiled_asset?' => true)
      assert_equal 'http://assets.domain.com/dummy.png', wicked_pdf_asset_path('dummy.png')
    end

    test 'wicked_pdf_asset_path should return a url with a protocol when assets are served by an asset server with no protocol set' do
      expects(:asset_path => 'assets.domain.com/dummy.png')
      expects('precompiled_asset?' => true)
      assert_equal 'http://assets.domain.com/dummy.png', wicked_pdf_asset_path('dummy.png')
    end

    test 'wicked_pdf_asset_path should return a path when assets are precompiled' do
      expects('precompiled_asset?' => false)
      path = wicked_pdf_asset_path('application.css')

      assert path.include?('/assets/stylesheets/application.css')
      assert path.include?('file:///')
    end

    test 'WickedPdfHelper::Assets::ASSET_URL_REGEX should match various URL data type formats' do
      assert_match WickedPdfHelper::Assets::ASSET_URL_REGEX, 'url(\'/asset/stylesheets/application.css\');'
      assert_match WickedPdfHelper::Assets::ASSET_URL_REGEX, 'url("/asset/stylesheets/application.css");'
      assert_match WickedPdfHelper::Assets::ASSET_URL_REGEX, 'url(/asset/stylesheets/application.css);'
      assert_match WickedPdfHelper::Assets::ASSET_URL_REGEX, 'url(\'http://assets.domain.com/dummy.png\');'
      assert_match WickedPdfHelper::Assets::ASSET_URL_REGEX, 'url("http://assets.domain.com/dummy.png");'
      assert_match WickedPdfHelper::Assets::ASSET_URL_REGEX, 'url(http://assets.domain.com/dummy.png);'
      assert_no_match WickedPdfHelper::Assets::ASSET_URL_REGEX, '.url { \'http://assets.domain.com/dummy.png\' }'
    end

    test 'set_protocol should properly set the protocol when the asset is precompiled' do
      assert_equal 'http://assets.domain.com/dummy.png', set_protocol('//assets.domain.com/dummy.png')
      assert_equal '/assets.domain.com/dummy.png', set_protocol('/assets.domain.com/dummy.png')
      assert_equal 'http://assets.domain.com/dummy.png', set_protocol('http://assets.domain.com/dummy.png')
      assert_equal 'https://assets.domain.com/dummy.png', set_protocol('https://assets.domain.com/dummy.png')
    end
  end
end
