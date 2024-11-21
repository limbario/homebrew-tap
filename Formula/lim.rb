class Lim < Formula
  desc "Get remote Android instances for local development and testing"
  homepage "https://limbar.io"
  version "v0.8.2"
  license "Proprietary"

  depends_on "limbario/tap/adb"
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
      sha256 "a62bd82047ccaed9bb9a3d610423d3689385eacf8e2c2abc2166d1ab9a8f89c6" # replace_with_darwin_arm64_sha256
    else
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-darwin-amd64"
      sha256 "c8a0d42731e48d02808773b5fb798a637ca7277eb225d0f6ef6ac4d79251c095" # replace_with_darwin_amd64_sha256
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-linux-arm64"
      sha256 "17bd4ae0029417786d84b7dc78cc375918ecadee18ecdac39c55b4d1d5ffc2f1" # replace_with_linux_arm64_sha256
    else
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-linux-amd64"
      sha256 "b8b8df10286daa4a88c8f60cce4687409b05722a91cc854f2f9eac00207e18ef" # replace_with_linux_amd64_sha256
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
