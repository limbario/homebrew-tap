class Lim < Formula
  desc "Get remote Android instances for local development and testing"
  homepage "https://limbar.io"
  version "v0.9.0"
  license "Proprietary"

  depends_on "limbario/tap/adb"

  def caveats
    <<~EOS
      Get started with:
        lim run android
    EOS
  end

  on_macos do
    if Hardware::CPU.arm?
      depends_on "limbario/tap/scrcpy"

      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-darwin-arm64"
      sha256 "d2e57f77046ed7d37e1545118100604086f9bb2ea1c68fe4e2e32e41683aedd8" # replace_with_darwin_arm64_sha256
    else
      # scrcpy does not yet publish static builds for darwin-amd64
      depends_on "scrcpy"

      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-darwin-amd64"
      sha256 "50bb7683ec134b1feac04520ef9b457e71572f60fb2fe0744262ed1462355402" # replace_with_darwin_amd64_sha256
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      # scrcpy does not yet publish static builds for linux-arm64
      depends_on "scrcpy"

      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-linux-arm64"
      sha256 "c5a5a73a0ef09fc151eb1c09c9a58d0d7cf9c74da89c79a10a2749211d5d9ec2" # replace_with_linux_arm64_sha256
    else
      depends_on "limbario/tap/scrcpy"

      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-linux-amd64"
      sha256 "f5bee90ee8583708e349ba82fddfaf0f42da53f51ec6a7321a0c1c9f04f1dd91" # replace_with_linux_amd64_sha256
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
