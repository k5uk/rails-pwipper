require 'spec_helper' #最初の行では、Homeページに対するテストであることを記述しています。これは単なる文字列であり、好きな文字列を使用できます。RSpecはこの文字列を解釈しないので、人間にとってわかりやすい説明をここに書くようにします。

describe "StaticPages" do
  describe "Home page" do
    it "should have the content 'Sample App'" do
      #/static_pages/homeのHomeページにアクセスしたとき、“Sample App”という語が含まれていなければならない
      visit '/static_pages/home' #Capybaraのvisit機能を使って、ブラウザでの/static_pages/homeURLへのアクセスをシミュレーション
      expect(page).to have_content('Sample App') #Capybaraが提供するpage変数を使って、アクセスした結果のページに正しいコンテンツが表示されているかどうかをテスト
    end
  end

  it "should have the right title" do
    visit '/static_pages/home'
    expect(page).to have_title("Ruby on Rails Tutorial Sample App | Home")
  end

  describe "Help page" do

    it "should have the content 'Help'" do
      visit '/static_pages/help'
      expect(page).to have_content('Help')
    end
  end

  it "should have the right title" do
    visit '/static_pages/help'
    expect(page).to have_title("Ruby on Rails Tutorial Sample App | Help")
  end

  describe "About page" do

    it "should have the content 'About Us'" do
      visit '/static_pages/about'
      expect(page).to have_content('About Us')
    end

    it "should have the right title" do
      visit '/static_pages/about'
      expect(page).to have_title("Ruby on Rails Tutorial Sample App | About Us")
    end

  end
end
