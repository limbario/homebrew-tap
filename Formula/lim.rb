class Lim < Formula
  desc "Get remote Android instances for local development and testing"
  homepage "https://limbar.io"
  version "v0.11.0"
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
      sha256 "3b4bc0b899bde9d975d1374727b63d4310cb0ed3e11a3356843031060c2a604c" # replace_with_darwin_arm64_sha256
    else
      # scrcpy does not yet publish static builds for darwin-amd64
      depends_on "scrcpy"

      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-darwin-amd64"
      sha256 "e60fb11c75654b7ec9aaa4e08e59da9878e48b30fabe587253bd27bd38a607f3" # replace_with_darwin_amd64_sha256
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      # scrcpy does not yet publish static builds for linux-arm64
      depends_on "scrcpy"

      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-linux-arm64"
      sha256 "8e257c9c08e90de7aa67fc357af60fa0319b62d2882504fe7c7e37477e00d5dd" # replace_with_linux_arm64_sha256
    else
      depends_on "limbario/tap/scrcpy"

      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-linux-amd64"
      sha256 "f5f45e4ca7afad2a980108cd28af1c28fd0e61499214a32c88f69a5112a409a9" # replace_with_linux_amd64_sha256
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
