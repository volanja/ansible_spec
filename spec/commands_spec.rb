# coding: utf-8
require 'ansible_spec'

created_file = [
"spec/spec_helper.rb",
"Rakefile",
".ansiblespec"
]
created_dir = [
"spec",
]
test_dir = "tmp"

describe "テスト" do
  # テスト実行前
  before(:all) do
    $stdout = File.open("/dev/null", "w") #テスト実行中は標準出力は/dev/nullにする。
    FileUtils.mkdir_p(test_dir) unless FileTest.exist?(test_dir)
    Dir.chdir(test_dir) #tmp/に移動
    AnsibleSpec.main
  end

  # テスト実行後
  after(:all) do
    created_file.each{|f| File.delete(f) }
    created_dir.each{|d| Dir.delete(d) }
    Dir.chdir("../")
    Dir.delete(test_dir)
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

end
