class Lim < Formula
  desc "Get remote Android instances for local development and testing"
  homepage "https://limbar.io"
  version "v0.1.0"
  license "Proprietary"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-darwin-arm64"
      sha256 "replace_with_darwin_arm64_sha256" # replace_with_darwin_arm64_sha256
    else
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-darwin-amd64"
      sha256 "replace_with_darwin_amd64_sha256" # replace_with_darwin_amd64_sha256
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-linux-arm64"
      sha256 "replace_with_linux_arm64_sha256" # replace_with_linux_arm64_sha256
    else
      url "https://github.com/limbario/homebrew-lim/releases/download/#{version}/lim-linux-amd64"
      sha256 "replace_with_linux_amd64_sha256" # replace_with_linux_amd64_sha256
    end
  end

  def install
    bin.install "lim"
  end

  test do
    system "#{bin}/lim", "--version"
  end
end
