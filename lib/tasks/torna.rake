# frozen_string_literal: true

namespace :torna do
  desc "Print all routes and upload to tornado"
  task :print_and_upload do
    torna_apis = routes_to_torna_apis

    torna_apis.each do |api|
      puts "#{api["httpMethod"]} #{api["url"]}"
    end

    upload_routes(torna_apis)
  end

  def routes_to_torna_apis
    Rails.application.reload_routes!
    routes = Rails.application.routes.routes

    routes.map do |route|
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
        "name" => "#{route.verb} #{route.path.spec}",
        "type" => 0,
        "url" => route.path.spec.to_s,
        "httpMethod" => route.verb.to_s,
        "contentType" => route.defaults[:format] || "application/json",
        "isFolder" => 0,
        "isShow" => 1,
        "pathParams" => route.path.required_names.map { |name| { "name" => name, "type" => "string" } }
      }
    end
  end

  def upload_routes(torna_apis)
    require "net/http"
    require "uri"
    require "json"

    uri = URI.parse(ENV["TORNADO_URL"])
    access_token = ENV["TORNADO_ACCESS_TOKEN"]

    raise "Please set TORNADO_URL and TORNADO_ACCESS_TOKEN" if uri.nil? || access_token.nil?

    header = { 'Content-Type': "application/json" }

    data = {
      "debugEnvs" => [],
      "commonErrorCodes" => [],
      "isReplace" => 0,
      "isOverride" => 0,
      "apis" => torna_apis
    }

    request_body = {
      access_token: access_token,
      name: "doc.push",
      version: "1.0",
      data: URI.encode_www_form_component(data.to_json)
    }

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = request_body.to_json

    response = http.request(request)

    if response.code == "200"
      puts "Success: #{response.code} #{response.body}"
    else
      puts "Error: #{response.code} #{response.body}"
    end
  end
end
