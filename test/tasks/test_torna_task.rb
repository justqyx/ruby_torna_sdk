# frozen_string_literal: true

require "test_helper"

require "rails"
require "rake"
require "webmock/minitest"

module TestApp
  class Application < Rails::Application
    config.eager_load = false
  end
end

class TornaTaskTest < Minitest::Test
  def setup
    Rails.application = TestApp::Application.new
    Rails.application.load_tasks

    Rails.application.routes.draw do
      get "test/index"
      post "test/create"
      put "test/update"
      delete "test/destroy"
    end
  end

  def test_torna_print_and_upload
    WebMock.enable!

    stub_request(:post, "http://localhost:7700/api").to_return do |_request|
      { status: 200, body: '{"code":"0","data":{},"msg":""}' }
    end

    Rake::Task["torna:print_and_upload"].invoke

    # 我不知道为何这里是两次请求
    assert_requested(:post, "http://localhost:7700/api", times: 2)
  ensure
    WebMock.disable!
  end
end
