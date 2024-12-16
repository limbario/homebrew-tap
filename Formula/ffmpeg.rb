class Ffmpeg < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  version "6.0"
  license "GPL-2.0-or-later"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/eugeneware/ffmpeg-static/releases/download/b#{version}/ffmpeg-darwin-arm64.gz"
      sha256 "6be74d6f449889c2e87a75873894f8520cad56c08ac76f2a628d85b0519daaca"
    else
      url "https://github.com/eugeneware/ffmpeg-static/releases/download/b#{version}/ffmpeg-darwin-x64.gz"
      sha256 "a12354fce7eb62361473bbe10d53a1893695babd35869ec8e92e5dfea8d0440b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/eugeneware/ffmpeg-static/releases/download/b#{version}/ffmpeg-linux-arm64.gz"
      sha256 "2b708b2d15041d2a192c1db24c7a8a1d24f645a8242dce1c744ff2392b86ada1"
    else
      url "https://github.com/eugeneware/ffmpeg-static/releases/download/b#{version}/ffmpeg-linux-x64.gz"
      sha256 "17c1ae10b52ac499180679fe6ba77e17642390c4eedb0f1e3b0ac045da55128f"
    end
  end

  def install
    binary_name = "ffmpeg"

    if OS.mac?
      binary_path = Hardware::CPU.arm? ? "ffmpeg-darwin-arm64" : "ffmpeg-linux-x64"
    elsif OS.linux?
      binary_path = Hardware::CPU.arm? ? "ffmpeg-linux-arm64" : "ffmpeg-linux-x64"
    end

    bin.install binary_path => binary_name
  end

  test do
    system "#{bin}/ffmpeg", "-version"
  end
end
