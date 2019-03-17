require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe "full_titleメソッドの検証" do
    context "引数がない場合" do
      it "デフォルトのタイトルを返す" do
        expect(full_title).to eq "Hoshiimo"
      end
    end

    context "引数がある場合" do
      it "引数に合わせたタイトル名を返す" do
        expect(full_title("foobar")).to eq "foobar | Hoshiimo"
      end
    end
  end
end
