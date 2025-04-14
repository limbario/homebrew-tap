class Adb < Formula
  desc "Communicate with Android devices"
  homepage "https://developer.android.com/tools/releases/platform-tools"
  version "v35.0.2-12147458"
  license "Apache-2.0"
  # Source code is in https://android.googlesource.com/platform/packages/modules/adb

  on_macos do
    url "https://dl.google.com/android/repository/platform-tools-latest-darwin.zip"
    sha256 "b241878e6ec20650b041bf715ea05f7d5dc73bd24529464bd9cf68946e3132bd"
  end

  on_linux do
    url "https://dl.google.com/android/repository/platform-tools-latest-linux.zip"
    sha256 "0ead642c943ffe79701fccca8f5f1c69c4ce4f43df2eefee553f6ccb27cbfbe8"
  end

  def install
    bin.install "adb"
  end

  test do
    system "#{bin}/adb", "--version"
  end
end
