class ListData < ActiveRecord::Base      
  self.table_name = 'article_list'
end

class ListDetailData < ActiveRecord::Base
  self.table_name = 'article_details'
end

class ArticleController < ApplicationController

  def hello
    personal = {'name' => 'Yamada', 'old' => 28}
    render :json => personal
  end


  def getList
    @list_all = ListData.all
    @list_one = ListData.where(article_id: 212)

#    @drivers = {'name' => 'Yamada', 'old' => 28}
#    render :json =>  @drivers
    render :json => @list_all
  end


  def getDetail
    @detail_all = ListDetailData.all
    @detail_one = ListDetailData.where(article_id: params[:article_id])

#    render :json => @detail_all
    render :json => @detail_one
  end

end
