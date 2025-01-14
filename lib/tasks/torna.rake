# frozen_string_literal: true

namespace :torna do
  desc "Print all routes and upload to tornado"
  task print_and_upload: :environment do
    Rails.application.reload_routes!
    routes = Rails.application.routes.routes

    author = ENV["AUTHOR"] || ""

    torna_apis = routes.map do |route|
      # {
      #    "name": "获取商品信息",
      #    "description": "获取商品信息",
      #    "author": "李四",
      #    "deprecated": "该接口已废弃，改成:/user/list",
      #    "type": 0,
      #    "url": "/goods/get",
      #    "version": "1.0",
      #    "definition": "Result<Order> getOrder(String orderNo)",
      #    "httpMethod": "GET",
      #    "contentType": "application/json",
      #    "isFolder": 1,
      #    "isShow": 1,
      #    "orderIndex": 0,
      #    "isRequestArray": 0,
      #    "isResponseArray": 0,
      #    "requestArrayType": "object",
      #    "responseArrayType": "object",
      #    "dubboInfo": {
      #        "interfaceName": "com.xx.doc.dubbo.DubboInterface",
      #        "author": "yu 2020/7/29.",
      #        "version": "1.0",
      #        "protocol": "dubbo",
      #        "dependency": "<dependency>...</dependency>"
      #    },
      #    "pathParams": [
      #        {
      #            "name": "goodsName",
      #            "type": "string/array/object",
      #            "required": 1,
      #            "maxLength": "128",
      #            "example": "iphone12",
      #            "description": "商品名称描述",
      #            "parentId": "string",
      #            "enumInfo": {
      #                "name": "支付枚举",
      #                "description": "支付状态",
      #                "items": [
      #                    {
      #                        "name": "WAIT_PAY",
      #                        "type": "string",
      #                        "value": "0",
      #                        "description": "未支付"
      #                    }
      #                ]
      #            },
      #            "children": [],
      #            "orderIndex": 1
      #        }
      #    ],
      #    "headerParams": [
      #        {
      #            "name": "token",
      #            "type": "string/array/object",
      #            "required": 1,
      #            "example": "iphone12",
      #            "description": "商品名称描述",
      #            "enumInfo": {
      #                "name": "支付枚举",
      #                "description": "支付状态",
      #                "items": [
      #                    {
      #                        "name": "WAIT_PAY",
      #                        "type": "string",
      #                        "value": "0",
      #                        "description": "未支付"
      #                    }
      #                ]
      #            }
      #        }
      #    ],
      #    "queryParams": [
      #        {
      #            "name": "goodsName",
      #            "type": "string/array/object",
      #            "required": 1,
      #            "maxLength": "128",
      #            "example": "iphone12",
      #            "description": "商品名称描述",
      #            "parentId": "string",
      #            "enumInfo": {
      #                "name": "支付枚举",
      #                "description": "支付状态",
      #                "items": [
      #                    {
      #                        "name": "WAIT_PAY",
      #                        "type": "string",
      #                        "value": "0",
      #                        "description": "未支付"
      #                    }
      #                ]
      #            },
      #            "children": [],
      #            "orderIndex": 1
      #        }
      #    ],
      #    "requestParams": [
      #        {
      #            "name": "goodsName",
      #            "type": "string/array/object",
      #            "required": 1,
      #            "maxLength": "128",
      #            "example": "iphone12",
      #            "description": "商品名称描述",
      #            "parentId": "string",
      #            "enumInfo": {
      #                "name": "支付枚举",
      #                "description": "支付状态",
      #                "items": [
      #                    {
      #                        "name": "WAIT_PAY",
      #                        "type": "string",
      #                        "value": "0",
      #                        "description": "未支付"
      #                    }
      #                ]
      #            },
      #            "children": [],
      #            "orderIndex": 1
      #        }
      #    ],
      #    "responseParams": [
      #        {
      #            "name": "goodsName",
      #            "type": "string/array/object",
      #            "required": 1,
      #            "maxLength": "128",
      #            "example": "iphone12",
      #            "description": "商品名称描述",
      #            "parentId": "string",
      #            "enumInfo": {
      #                "name": "支付枚举",
      #                "description": "支付状态",
      #                "items": [
      #                    {
      #                        "name": "WAIT_PAY",
      #                        "type": "string",
      #                        "value": "0",
      #                        "description": "未支付"
      #                    }
      #                ]
      #            },
      #            "children": [],
      #            "orderIndex": 1
      #        }
      #    ],
      #    "errorCodeParams": [
      #        {
      #            "code": "10001",
      #            "msg": "token错误",
      #            "solution": "请填写token"
      #        }
      #    ],
      #    "items": []
      # }
      {
        "isFolder" => 0,
        "isShow" => 1,
        "type" => 0,
        "author" => author,
        "name" => "#{route.verb} #{route.path.spec}",
        "url" => route.path.spec.to_s,
        "httpMethod" => route.verb.to_s,
        "contentType" => route.defaults[:format] || "application/json",
        "pathParams" => route.path.required_names.map { |name| { "name" => name, "type" => "string" } }
      }
    end

    require "net/http"
    require "uri"
    require "json"

    uri = URI.parse(ENV["TORNADO_URL"])
    access_token = ENV["TORNADO_ACCESS_TOKEN"]
    git_url = ENV["GIT_URL"]
    branch = ENV["GIT_BRANCH"]

    is_replace = ENV["IS_REPLACE"] || "1"
    is_override = ENV["IS_OVERRIDE"] || "0"

    raise "Please set TORNADO_URL and TORNADO_ACCESS_TOKEN" if uri.nil? || access_token.nil?

    header = { 'Content-Type': "application/json" }

    data = {
      "debugEnvs" => [],
      "commonErrorCodes" => [],
      "isReplace" => is_replace.to_i,
      "isOverride" => is_override.to_i,
      "apis" => torna_apis
    }

    data["gitUrl"] = git_url if git_url
    data["moduleName"] = branch if branch

    request_body = {
      access_token: access_token,
      name: "doc.push",
      version: "1.0",
      data: URI.encode_www_form_component(data.to_json),
      timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S")
    }

    # print request body
    puts "========== Request:"
    puts request_body.to_json
    puts "=========="

    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = request_body.to_json
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    if response.code == "200"
      puts "Success: #{response.code} #{response.body}"
    else
      puts "Error: #{response.code} #{response.body}"
    end
  end
end
