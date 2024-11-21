class Lim < Formula
  desc "Get remote Android instances for local development and testing"
  homepage "https://limbar.io"
  version "v0.8.3"
  license "Proprietary"

  depends_on "limbario/tap/adb"
  depends_on "limbario/tap/scrcpy"

  def caveats
    <<~EOS
      Get started with:
        lim run android
    EOS
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-darwin-arm64"
      sha256 "424301f32c4b61987f51e069f58ed1393cf8f9ebf13c70a735e10371280f50c5" # replace_with_darwin_arm64_sha256
    else
      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-darwin-amd64"
      sha256 "3a7c56b78c00ea638332dc9a0f13067d49291900a3cd809c6fddd21f90acca83" # replace_with_darwin_amd64_sha256
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-linux-arm64"
      sha256 "a53a3d33ed4c2e1105c89476400643b8d4d081ebfe919fa3c2d5a91a62674958" # replace_with_linux_arm64_sha256
    else
      url "https://github.com/limbario/homebrew-tap/releases/download/#{version}/lim-linux-amd64"
      sha256 "e7f5e91385900055d296eedde9a105c5d1b67e9559d10ed806b231ac6af70e84" # replace_with_linux_amd64_sha256
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
