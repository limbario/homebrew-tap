class Scrcpy < Formula
  desc "Display and control your Android device"
  homepage "https://github.com/Genymobile/scrcpy"
  version "v2.7"
  license "Apache-2.0"

  depends_on "limbario/tap/adb"

  resource "prebuilt-server" do
    url "https://github.com/Genymobile/scrcpy/releases/download/#{version}/scrcpy-server-#{version}", using: :nounzip
    sha256 "a23c5659f36c260f105c022d27bcb3eafffa26070e7baa9eda66d01377a1adba"
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://raw.githubusercontent.com/limbario/homebrew-tap/refs/heads/main/bin/scrcpy-#{version}-darwin-arm64"
      sha256 "48612d8f9f0a51f3161d93555ed325435948960b2946d4793907f0f9bb5b7760" # replace_with_darwin_arm64_sha256
    else
      odie "This formula is not compatible with darwin-amd64. Please use `brew install scrcpy`"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      odie "This formula is not compatible with linux-arm64. Please use `brew install scrcpy`"
    else
      url "https://raw.githubusercontent.com/limbario/homebrew-tap/refs/heads/main/bin/scrcpy-#{version}-linux-amd64"
      sha256 "6696e27efeffb0b3de9f391ec35ccf4bba409eb3b010fd4cf3d1b3b37941d60e" # replace_with_linux_amd64_sha256
    end
  end

  def install
    binary_name = "scrcpy"
    binary_path = "scrcpy"

    if OS.mac?
      binary_path = Hardware::CPU.arm? ? "scrcpy-darwin-arm64" : "scrcpy-darwin-amd64"
    elsif OS.linux?
      binary_path = Hardware::CPU.arm? ? "scrcpy-linux-arm64" : "scrcpy-linux-amd64"
    end

    bin.install binary_path => binary_name
    buildpath.install resource("prebuilt-server")
  end

  test do
    system "#{bin}/scrcpy", "--version"
  end
end
