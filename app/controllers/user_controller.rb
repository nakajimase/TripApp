
class UserListData < ActiveRecord::Base
  self.table_name = 'user_list'
end

class UserController < ApplicationController

protect_from_forgery with: :null_session
  def hello
    personal = {'name' => 'Yamada', 'old' => 28}
    render :json => personal
  end

  def userAdd
    user = UserListData.create('user_name' => params[:email_address], 'password' => params[:password], 'email' => params[:email_address])
#    user = UserListData.create('user_name' => 'test', 'password' => 'test', 'email' => 'test')
    render :json => user
  end
end

