# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

##
# A Net::HTTP connection wrapper that holds extra information for managing the
# connection's lifetime.

module Vault
class PersistentHTTP::Connection # :nodoc:

  attr_accessor :http

  attr_accessor :last_use

  attr_accessor :requests

  attr_accessor :ssl_generation

  def initialize http_class, http_args, ssl_generation
    @http           = http_class.new(*http_args)
    @ssl_generation = ssl_generation

    reset
  end

  def finish
    @http.finish
  rescue IOError
  ensure
    reset
  end

  def reset
    @last_use = PersistentHTTP::EPOCH
    @requests = 0
  end

  def ressl ssl_generation
    @ssl_generation = ssl_generation

    finish
  end

end
end
