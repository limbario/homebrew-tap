class AdbRequirement < Requirement
  fatal true

  satisfy(build_env: false) { which("adb") }

  def message
    <<~EOS
      Android Debug Bridge (adb) is required to use lim.
      You can install it via Android Studio or with:
        brew install --cask android-platform-tools
    EOS
  end
end

class Lim < Formula
  desc "Get remote Android instances for local development and testing"
  homepage "https://limbar.io"
  version "v0.8.0"
  license "Proprietary"

  depends_on AdbRequirement
  depends_on "scrcpy"

  def caveats
    <<~EOS
      Get started with:
        lim run android
    EOS
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-darwin-arm64"
      sha256 "ab06d56551c07953adace4fc377e92fb51f0dc5f4b379991735bb45804a239c5" # replace_with_darwin_arm64_sha256
    else
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-darwin-amd64"
      sha256 "d99e4db1525c40bbd71108d6edbffc228611e3717d830ee28a94251e755b81d8" # replace_with_darwin_amd64_sha256
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-linux-arm64"
      sha256 "b0d20d992a062b65fa8b15358dffe1b553e8b11996dc6edb16b115a1ed473e91" # replace_with_linux_arm64_sha256
    else
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-linux-amd64"
      sha256 "f8d884b06b75bb0c3f2970e9914587546f79ee4a91e9ec6785221df100c56f3b" # replace_with_linux_amd64_sha256
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
