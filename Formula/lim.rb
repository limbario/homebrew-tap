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
  version "v0.7.4"
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
      sha256 "e160a38b0c1051365248078a0597135460f24990cde6cf9854c666c90d861490" # replace_with_darwin_arm64_sha256
    else
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-darwin-amd64"
      sha256 "c8a29d561bddaca71a3caa497d54eb79cf7b3f8ae1a71d292f0db426cd632af4" # replace_with_darwin_amd64_sha256
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-linux-arm64"
      sha256 "b51ea6520f3c1b155f24abb1b9504f0506760acb6c000da0f8a5850f1bfc1620" # replace_with_linux_arm64_sha256
    else
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-linux-amd64"
      sha256 "87e00e9076a0d208cc6c4bc03d551adb486d18f34e707a134020e163cc0fabd9" # replace_with_linux_amd64_sha256
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
