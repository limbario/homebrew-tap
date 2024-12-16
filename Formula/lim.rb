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
  version "v0.8.1"
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
      sha256 "e252a95d5ce1db328e20806b7b2b38280bd7dfe9ec2bb1151e8e791f3a9fac82" # replace_with_darwin_arm64_sha256
    else
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-darwin-amd64"
      sha256 "a51098a38b75f82ee62867e34f3582d2c8cb1bec31ea4a6b5c21942baa076f01" # replace_with_darwin_amd64_sha256
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-linux-arm64"
      sha256 "a3a615e116ce9c18a95b1269a34e6d7442eb87167f67a0bf07a67d416a40a618" # replace_with_linux_arm64_sha256
    else
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-linux-amd64"
      sha256 "f3d5d5ed5269051fd2cfb774b8e2a81e4e781b7e9ad8074d50b991de94d3f89c" # replace_with_linux_amd64_sha256
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
