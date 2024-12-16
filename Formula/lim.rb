class Lim < Formula
  desc "Get remote Android instances for local development and testing"
  homepage "https://limbar.io"
  version "v0.8.7"
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
      sha256 "9ecfc3fbb97d1fa1c584524dbb4bf3a5eb663c0c2cd21809ce91b8dfa8d75788" # replace_with_darwin_arm64_sha256
    else
      # scrcpy does not yet publish static builds for darwin-amd64
      depends_on "scrcpy"

      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-darwin-amd64"
      sha256 "e9630e2e57acf5ef5b5b0e16b8faca646fe747c93e853f2c30ef42918ae79ad1" # replace_with_darwin_amd64_sha256
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      # scrcpy does not yet publish static builds for linux-arm64
      depends_on "scrcpy"

      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-linux-arm64"
      sha256 "f81591ff73eafa4b6af1dc82ad7126670455f1e9cfd749bf6fabffca1ce5890a" # replace_with_linux_arm64_sha256
    else
      depends_on "limbario/tap/scrcpy"

      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-linux-amd64"
      sha256 "0ad5255bde9981e1c305228ba76532f8705c6eb9719ee1c381e8eb1b93315787" # replace_with_linux_amd64_sha256
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
