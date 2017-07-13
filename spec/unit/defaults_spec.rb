require "spec_helper"

module Vault
  describe Defaults do
    describe ".options" do
      it "returns a hash" do
        expect(Defaults.options).to be_a(Hash)
      end
    end

    describe ".address" do
      it "uses ENV['VAULT_ADDR'] if present" do
        with_stubbed_env("VAULT_ADDR" => "test") do
          expect(Defaults.address).to eq("test")
        end
      end

      it "falls back to the default VAULT_ADDRESS" do
        with_stubbed_env("VAULT_ADDR" => nil) do
          expect(Defaults.address).to eq(Defaults::VAULT_ADDRESS)
        end
      end

      it "falls back to config file" do
        with_stubbed_env("VAULT_ADDR" => nil) do
          with_stubbed_config(address: "specTestAddress") do
            expect(Defaults.address).to eq("specTestAddress")
          end
        end
      end
    end

    describe ".token" do
      let(:token) { File.expand_path("~/.vault-token") }
      let(:backup_token) { File.expand_path("~/.vault-token.old") }

      before do
        if File.exist?(token)
          FileUtils.mv(token, backup_token)
        end
      end

      after do
        if File.exist?(backup_token)
          FileUtils.mv(backup_token, token)
        end
      end

      it "uses token from config file" do
        with_stubbed_env("VAULT_TOKEN" => nil) do
          with_stubbed_config(token: "specToken") do
            expect(Defaults.token).to eq("specToken")
          end
        end
      end

      it "uses ~/.vault-token when present over config file" do
        with_stubbed_config(token: "specToken") do
          File.open(token, "w") { |f| f.write("testing\n") }
          expect(Defaults.token).to eq("testing")
        end
      end

      it "uses ENV['VAULT_TOKEN'] if present" do
        with_stubbed_env("VAULT_TOKEN" => "testing") do
          expect(Defaults.token).to eq("testing")
        end
      end

      it "prefers the environment over local token and config file" do
        File.open(token, "w") { |f| f.write("testing1\n") }
        with_stubbed_env("VAULT_TOKEN" => "testing2") do
          with_stubbed_config(token: "specToken") do
            expect(Defaults.token).to eq("testing2")
          end
        end
      end
    end

    describe ".hostname" do
      it "defaults to ENV['VAULT_TLS_SERVER_NAME']" do
        with_stubbed_env("VAULT_TLS_SERVER_NAME" => "www.foo.com") do
          expect(Defaults.hostname).to eq("www.foo.com")
        end
      end

      it "falls back to config file" do
        with_stubbed_env("VAULT_TLS_SERVER_NAME" => nil) do
          with_stubbed_config(hostname: "specHostname") do
            expect(Defaults.hostname).to eq("specHostname")
          end
        end
      end
    end

    describe ".open_timeout" do
      it "defaults to ENV['VAULT_OPEN_TIMEOUT']" do
        with_stubbed_env("VAULT_OPEN_TIMEOUT" => "30") do
          expect(Defaults.open_timeout).to eq("30")
        end
      end

      it "falls back to config file" do
        with_stubbed_env("VAULT_OPEN_TIMEOUT" => nil) do
          with_stubbed_config(open_timeout: "500") do
            expect(Defaults.open_timeout).to eq("500")
          end
        end
      end
    end

    describe ".proxy_address" do
      it "defaults to ENV['VAULT_PROXY_ADDRESS']" do
        with_stubbed_env("VAULT_PROXY_ADDRESS" => "30") do
          expect(Defaults.proxy_address).to eq("30")
        end
      end

      it "falls back to config file" do
        with_stubbed_env("VAULT_PROXY_ADDRESS" => nil) do
          with_stubbed_config(proxy_address: "specProxyAddress") do
            expect(Defaults.proxy_address).to eq("specProxyAddress")
          end
        end
      end
    end

    describe ".proxy_username" do
      it "defaults to ENV['VAULT_PROXY_USERNAME']" do
        with_stubbed_env("VAULT_PROXY_USERNAME" => "30") do
          expect(Defaults.proxy_username).to eq("30")
        end
      end

      it "falls back to config file" do
        with_stubbed_env("VAULT_PROXY_USERNAME" => nil) do
          with_stubbed_config(proxy_username: "specProxyUsername") do
            expect(Defaults.proxy_username).to eq("specProxyUsername")
          end
        end
      end
    end

    describe ".proxy_password" do
      it "defaults to ENV['VAULT_PROXY_PASSWORD']" do
        with_stubbed_env("VAULT_PROXY_PASSWORD" => "30") do
          expect(Defaults.proxy_password).to eq("30")
        end
      end

      it "falls back to config file" do
        with_stubbed_env("VAULT_PROXY_PASSWORD" => nil) do
          with_stubbed_config(proxy_password: "specProxyPassword") do
            expect(Defaults.proxy_password).to eq("specProxyPassword")
          end
        end
      end
    end

    describe ".proxy_port" do
      it "defaults to ENV['VAULT_PROXY_PORT']" do
        with_stubbed_env("VAULT_PROXY_PORT" => "30") do
          expect(Defaults.proxy_port).to eq("30")
        end
      end

      it "falls back to config file" do
        with_stubbed_env("VAULT_PROXY_PORT" => nil) do
          with_stubbed_config(proxy_port: "specProxyPort") do
            expect(Defaults.proxy_port).to eq("specProxyPort")
          end
        end
      end
    end

    describe ".read_timeout" do
      it "defaults to ENV['VAULT_READ_TIMEOUT']" do
        with_stubbed_env("VAULT_READ_TIMEOUT" => "30") do
          expect(Defaults.read_timeout).to eq("30")
        end
      end

      it "falls back to config file" do
        with_stubbed_env("VAULT_READ_TIMEOUT" => nil) do
          with_stubbed_config(read_timeout: "specReadTimeout") do
            expect(Defaults.read_timeout).to eq("specReadTimeout")
          end
        end
      end
    end

    describe ".ssl_ciphers" do
      it "defaults to ENV['VAULT_SSL_CIPHERS']" do
        with_stubbed_env("VAULT_SSL_CIPHERS" => "testing") do
          expect(Defaults.ssl_ciphers).to eq("testing")
        end
      end

      it "falls back to the config file" do
        with_stubbed_env("VAULT_SSL_CIPHERS" => nil) do
          with_stubbed_config(ssl_ciphers: "specSslCiphers") do
            expect(Defaults.ssl_ciphers).to eq("specSslCiphers")
          end
        end
      end

      it "falls back to the default SSL_CIPHERS" do
        with_stubbed_env("VAULT_SSL_CIPHERS" => nil) do
          with_stubbed_config(ssl_ciphers: nil) do
            expect(Defaults.ssl_ciphers).to eq(Defaults::SSL_CIPHERS)
          end
        end
      end
    end

    describe ".ssl_pem_contents" do
      it "defaults to ENV['VAULT_SSL_PEM_CONTENTS']" do
        with_stubbed_env("VAULT_SSL_PEM_CONTENTS" => "abcd-1234") do
          expect(Defaults.ssl_pem_contents).to eq("abcd-1234")
        end
      end

      it "falls back to the config file" do
        with_stubbed_env("VAULT_SSL_PEM_CONTENTS" => nil) do
          with_stubbed_config(ssl_pem_contents: "specPemContents") do
            expect(Defaults.ssl_pem_contents).to eq("specPemContents")
          end
        end
      end
    end

    describe ".ssl_pem_file" do
      it "defaults to ENV['VAULT_SSL_CERT']" do
        with_stubbed_env("VAULT_SSL_CERT" => "~/path/to/cert") do
          expect(Defaults.ssl_pem_file).to eq("~/path/to/cert")
        end
      end

      it "falls back to the config file" do
        with_stubbed_env("VAULT_SSL_CERT" => nil) do
          with_stubbed_config(ssl_pem_file: "specSslPemFile") do
            expect(Defaults.ssl_pem_file).to eq("specSslPemFile")
          end
        end
      end
    end

    describe ".ssl_pem_passphrase" do
      it "defaults to ENV['VAULT_SSL_CERT_PASSPHRASE']" do
        with_stubbed_env("VAULT_SSL_CERT_PASSPHRASE" => "testing") do
          expect(Defaults.ssl_pem_passphrase).to eq("testing")
        end
      end

      it "falls back to the config file" do
        with_stubbed_env("VAULT_SSL_CERT_PASSPHRASE" => nil) do
          with_stubbed_config(ssl_pem_passphrase: "specSslPemPassphrase") do
            expect(Defaults.ssl_pem_passphrase).to eq("specSslPemPassphrase")
          end
        end
      end
    end

    describe ".ssl_ca_cert" do
      it "defaults to ENV['VAULT_CACERT']" do
        with_stubbed_env("VAULT_CACERT" => "~/path/to/cert") do
          expect(Defaults.ssl_ca_cert).to eq("~/path/to/cert")
        end
      end

      it "falls back to the config file" do
        with_stubbed_env("VAULT_CACERT" => nil) do
          with_stubbed_config(ssl_ca_cert: "specCaCert") do
            expect(Defaults.ssl_ca_cert).to eq("specCaCert")
          end
        end
      end
    end

    describe ".ssl_ca_path" do
      it "defaults to ENV['VAULT_CAPATH']" do
        with_stubbed_env("VAULT_CAPATH" => "~/path/to/cert") do
          expect(Defaults.ssl_ca_path).to eq("~/path/to/cert")
        end
      end

      it "falls back to the config file" do
        with_stubbed_env("VAULT_CAPATH" => nil) do
          with_stubbed_config(ssl_ca_path: "specSslaPath") do
            expect(Defaults.ssl_ca_path).to eq("specSslCaPath")
          end
        end
      end
    end

    describe ".ssl_verify" do
      it "defaults to true" do
        expect(Defaults.ssl_verify).to be(true)
      end

      it "reads the value of ENV['VAULT_SKIP_VERIFY']" do
        with_stubbed_env("VAULT_SKIP_VERIFY" => true) do
          expect(Defaults.ssl_verify).to be(false)
        end
      end

      it "reads the value of ENV['VAULT_SSL_VERIFY']" do
        with_stubbed_env("VAULT_SSL_VERIFY" => false) do
          expect(Defaults.ssl_verify).to be(false)
        end
      end

      it "falls back to the config file" do
        with_stubbed_env("VAULT_SKIP_VERIFY" => nil, "VAULT_SSL_VERIFY" => nil) do
          with_stubbed_config(ssl_verify: false) do
            expect(Defaults.ssl_verify).to be(false)
          end
        end
      end
    end

    describe ".ssl_timeout" do
      it "defaults to ENV['VAULT_SSL_TIMEOUT']" do
        with_stubbed_env("VAULT_SSL_TIMEOUT" => "30") do
          expect(Defaults.ssl_timeout).to eq("30")
        end
      end

      it "falls back to the config file" do
        with_stubbed_env("VAULT_SSL_TIMEOUT" => nil) do
          with_stubbed_config(ssl_timeout: "specSslTimeout") do
            expect(Defaults.ssl_ciphers).to eq("specSslTimeout")
          end
        end
      end
    end

    describe ".timeout" do
      it "defaults to ENV['VAULT_TIMEOUT']" do
        with_stubbed_env("VAULT_TIMEOUT" => "30") do
          expect(Defaults.timeout).to eq("30")
        end
      end

      it "falls back to the config file" do
        with_stubbed_env("VAULT_TIMEOUT" => nil) do
          with_stubbed_config(timeout: "60") do
            expect(Defaults.timeout).to eq("60")
          end
        end
      end
    end
  end
end
