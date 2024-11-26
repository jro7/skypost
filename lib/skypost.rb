require "faraday"
require "json"
require_relative "skypost/client"
require_relative "skypost/version"

module Skypost
  class Error < StandardError; end
end
