class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  # form_forで送信先
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
