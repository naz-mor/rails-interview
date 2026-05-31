require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#back_navigation_path' do
    before do
      allow(helper.request).to receive(:host).and_return('example.test')
      allow(helper.request).to receive(:port).and_return(80)
    end

    it 'returns the fallback when there is no referrer without parsing a URI' do
      allow(helper.request).to receive(:referer).and_return(nil)

      expect(URI).not_to receive(:parse)
      expect(helper.back_navigation_path(fallback: '/fallback')).to eq('/fallback')
    end

    it 'uses the todo lists path as the default fallback' do
      allow(helper.request).to receive(:referer).and_return(nil)

      expect(helper.back_navigation_path).to eq(todo_lists_path)
    end

    it 'returns a same-host referrer path with query string' do
      allow(helper.request).to receive(:referer).and_return('http://example.test/todolists?page=2')

      expect(helper.back_navigation_path(fallback: '/fallback')).to eq('/todolists?page=2')
    end

    it 'returns a relative referrer path' do
      allow(helper.request).to receive(:referer).and_return('/todolists/1/edit')

      expect(helper.back_navigation_path(fallback: '/fallback')).to eq('/todolists/1/edit')
    end

    it 'returns the fallback when the referrer host differs' do
      allow(helper.request).to receive(:referer).and_return('http://other.test/todolists')

      expect(helper.back_navigation_path(fallback: '/fallback')).to eq('/fallback')
    end

    it 'returns the fallback when the referrer port differs' do
      allow(helper.request).to receive(:referer).and_return('http://example.test:3000/todolists')

      expect(helper.back_navigation_path(fallback: '/fallback')).to eq('/fallback')
    end

    it 'returns the fallback when the referrer URI is invalid' do
      allow(helper.request).to receive(:referer).and_return('http://%')

      expect(helper.back_navigation_path(fallback: '/fallback')).to eq('/fallback')
    end

    it 'returns the fallback when the same-host referrer has no request URI' do
      allow(helper.request).to receive(:referer).and_return('http://example.test/todolists')
      allow(helper).to receive(:referrer_request_uri).and_return('')

      expect(helper.back_navigation_path(fallback: '/fallback')).to eq('/fallback')
    end
  end

  describe '#referrer_request_uri' do
    it 'returns request_uri for absolute HTTP URIs' do
      expect(helper.send(:referrer_request_uri, URI.parse('http://example.test/todolists?page=2'))).to eq('/todolists?page=2')
    end

    it 'returns the URI string for relative generic URIs' do
      expect(helper.send(:referrer_request_uri, URI.parse('/todolists/1/edit'))).to eq('/todolists/1/edit')
    end
  end

  describe '#same_host_referrer?' do
    before do
      allow(helper.request).to receive(:host).and_return('example.test')
      allow(helper.request).to receive(:port).and_return(80)
    end

    it 'accepts relative referrers without a host' do
      expect(helper.send(:same_host_referrer?, URI.parse('/todolists'))).to be(true)
    end

    it 'accepts referrers with the same host and port' do
      expect(helper.send(:same_host_referrer?, URI.parse('http://example.test/todolists'))).to be(true)
    end

    it 'rejects referrers with a different host' do
      expect(helper.send(:same_host_referrer?, URI.parse('http://other.test/todolists'))).to be(false)
    end

    it 'rejects referrers with a different port' do
      expect(helper.send(:same_host_referrer?, URI.parse('http://example.test:3000/todolists'))).to be(false)
    end
  end
end
