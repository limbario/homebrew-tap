class Lim < Formula
  desc "Get remote Android instances for local development and testing"
  homepage "https://limbar.io"
  version "v0.8.4"
  license "Proprietary"

  depends_on "limbario/tap/adb"
  # depends_on "limbario/tap/scrcpy"
  depends_on "scrcpy"

  def caveats
    <<~EOS
      Get started with:
        lim run android
    EOS
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-darwin-arm64"
      sha256 "a9b5637bb20999bb580347ff12f3762a1f05b669505241ac4f179abd5078c15d" # replace_with_darwin_arm64_sha256
    else
      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-darwin-amd64"
      sha256 "16bb4f057e5a474293f464e1f961abb76e5550ec43007f04ac457c16000ad3d1" # replace_with_darwin_amd64_sha256
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-linux-arm64"
      sha256 "8b84e8dd27bf08db32f5f3eacacf1dc109138845a7d8674f226ae642668bb85a" # replace_with_linux_arm64_sha256
    else
      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-linux-amd64"
      sha256 "0f21cb13dc7cfc7423ad706e39fcd10e8baba0eed249bc2f59c3605e0b1b3e18" # replace_with_linux_amd64_sha256
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
