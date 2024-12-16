class AdbRequirement < Requirement
  fatal true

  satisfy(build_env: false) { which("adb") }

  def message
    <<~EOS
      adb is required to use lim.
      You can install it via Android Studio or with:
        brew install --cask android-platform-tools
    EOS
  end
end

class Lim < Formula
  desc "Get remote Android instances for local development and testing"
  homepage "https://limbar.io"
  version "v0.7.1"
  license "Proprietary"

  depends_on AdbRequirement
  depends_on "scrcpy"

  def caveats
    <<~EOS
      Get started with:
        lim create android
    EOS
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-darwin-arm64"
      sha256 "fd5672f7fe121d29fd47e0c5c8611dadb39f2b7c67a1757d9c985b111045caee" # replace_with_darwin_arm64_sha256
    else
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-darwin-amd64"
      sha256 "9cb9e13e6719fa199e8168016394d853681d8b3dc2b9df27ab096c3a492ac18c" # replace_with_darwin_amd64_sha256
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-linux-arm64"
      sha256 "5f9ed1e7a65dee6f1e945c37c115ec5b1c4f75c152e827f06d7449a012c0942b" # replace_with_linux_arm64_sha256
    else
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-linux-amd64"
      sha256 "8ee81bf0be5fe5e7299d408531df85534b63a17002c3dec4bbb6925b27ff9327" # replace_with_linux_amd64_sha256
    end
  end

  def install
    binary_name = "lim"
    binary_path = "lim"

    if OS.mac?
      binary_path = Hardware::CPU.arm? ? "lim-darwin-arm64" : "lim-darwin-amd64"
    elsif OS.linux?
      binary_path = Hardware::CPU.arm? ? "lim-linux-arm64" : "lim-linux-amd64"
    end

    bin.install binary_path => binary_name
  end

  test do
    system "#{bin}/lim", "--version"
  end
end
