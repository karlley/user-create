# user 作成 表示

User 作成 > DB保存、単体ページで表示

## purpose

form タグからDB に保存, 表示するまでの処理の流れを理解する

## environment

- mac OS catarina 10.16.3
- ruby 2.6.5
- ruby on rails 6.0.2.1

## setup

git 設定, push, サーバ立ち上げ

```
$ rails new user-create
$ git add .
$ git commit -m "first commit"
$ git remote add origin https://github.com/karlley/user-create.git
$ git push -u origin master
$ rails s -d
```

http://127.0.0.1:3000 にアクセスして表示確認


## controller

- generate でview, route が生成されるのでcontroller の生成が最初
- コントローラー名は複数形
- private メソッドはインデントを1段深くする

```
$ rails g controller User new show create
```

new, show, create アクション追加

```:app/controllers/users_controller.rb
class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  # form_for の送信先
  # strong parameters でparams を初期化してインスタンスをcreate
  def create
    @user = User.new(user_params)
    if @user.save
      # インスタンス作成時のflash
      flash[:success] = "User Created!"
      # user_url @user にリダイレクト
      redirect_to @user
    else
      render 'new'
    end
  end

  private

    # create アクション用のstrong parameters
    def user_params
      params.require(:user).permit(:name, :email)
    end

end
```

## model & DB

- モデル名は単数形
- 作成されたテーブル名は複数形になる
- `rails db:create` が必要なのかは不明？
- model 生成後には手を加えていない

```
$ rails g model User name:string email:string
$ rails db:migrate
```

console で保存できるか確認

```
$ rails c --sandbox

# user インスタンスを作成
>> user = User.new(name: "name", email: "email")

# user インスタンスが有効かどうか
>> user.valid?

# user インスタンスを保存
>> user.save

# 保存したインスタンスを確認
>> user
>> User.all
>> User.count
```

create アクションはインスタンス作成 > 保存まで完結できる

```
>> User.create(name: "name", email: "email")
```

### model の動きを理解する

- 下記ファイルをrails カレントディレクトリに作成し、model の動きを理解する
- `rails c --sandbox`  でインスタンスを作ってみて確認する

```:/sample_user.rb
# getter, setter をセットする
# @name, @email を使えるようにする
  attr_accessor :name, :email

# 空User を作れるようにする
  def initialize(attributes = {})
    @name  = attributes[:name]
    @email = attributes[:email]
  end

# @name と@email をくっつける
  def formatted_email
    "#{@name} <#{@email}>"
  end
end
```

## route

- new, resources 追加
- show アクションはresources を追加する事で機能する
- リソース名は複数形
- recources とresource は異なる(組み合わせる事でほとんどのroute をカバーできる)

```:config/routes.rb
Rails.application.routes.draw do
  # get 'users/new'
  get 'users/new', to:'users#new'
  resources :users
end
```

### route 記述の使い分け

- 基本 root_path -> '/'
- リダイレクト root_url  -> 'http://www.example.com/'

## view

show, new, application

### show.html.erb

インスタンス表示

```:show.html.erb
<h1>app/view/users/show.html.erb</h1>

<%= @user.name %>
<%= @user.email %>
```

### new.html.erb

インスタンス作成画面

```:new.html.erb
<h1>Users#new</h1>
<p>Find me in app/views/users/new.html.erb</p>

<%= form_for(@user) do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>
  <%= f.label :email %>
  <%= f.email_field :email %>
  <%= f.submit "Enter!" %>
<% end %>
```

### application.html.erb

- デバッグ情報
- flach表示

```:app/views/layouts/application.html.erb
<!DOCTYPE html>
<html>
  <head>
    <title>UserCreate</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <!-- flash area -->
    <% flash.each do |message_type, message| %>
      <%= message_type %> <%= message %>
    <% end %>
    <%= yield %>
    <!-- debug area -->
    <p>=========================================</p>
    <p> debug data</p>
    <%= debug(params) if Rails.env.development? %>
    <p>=========================================</p>
  </body>
</html>
```