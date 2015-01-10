# coding: utf-8
require 'ansible_spec'
require 'diff/lcs'

created_file = [
"spec/spec_helper.rb",
"Rakefile",
".ansiblespec"
]
created_dir = [
"spec",
]
test_dir = "tmp"

describe "モジュールの実行" do
  # テスト実行前
  before do
    $stdout = File.open("/dev/null", "w") #テスト実行中は標準出力は/dev/nullにする。
    FileUtils.mkdir_p(test_dir) unless FileTest.exist?(test_dir)
    Dir.chdir(test_dir) #tmp/に移動
    AnsibleSpec.main
  end

  # テスト実行後
  after do
    created_file.each{|f| File.delete(f) }
    created_dir.each{|d| Dir.delete(d) }
    Dir.chdir("../")
    FileUtils.remove_entry_secure(test_dir)
    #Dir.delete(test_dir)
    $stdout =STDOUT # テスト実行後は元に戻す
  end

  it "/tmpにディレクトリが作成されること" do
    created_dir.each{|d|
      expect(File.directory?(d)).to be_truthy
    }
  end

  it "/tmpにファイルが作成されること" do
    created_file.each{|f|
      expect(FileTest.exist?(f)).to be_truthy
    }
  end

  it "ファイルがオリジナルと一致すること" do
    created_file.each{|f|
      expect(no_diff("../lib/src/"+f,f)).to be_truthy
    }
  end

end

# check diff
# if exists diff, return false
# if not exist diff, return true
def no_diff(src_file,dst_file)
  src = File.open(src_file).read
  dst = File.open(dst_file).read
  if Diff::LCS.diff(src,dst).count == 0
    return true
  end
  return false
end
